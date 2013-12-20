# encoding: utf-8

module RandomSelectionHelper
  # The completeness check is rather expensive. The idea is to request
  # more questions than required and exclude them later if they are
  # found to be incomplete. The trade off made is that we might be a
  # few questions short in some cases, but are faster on average. By
  # default 5 questions are presented each run, thus the default factor
  # of 1.6 loads three additional questions. If this value is too low,
  # a warning will logged (grep for INCREASE_FACTOR).
  INCREASE_FACTOR = 1.6

  # retrieves cnt questions out of the given set. The set may contain
  # incomplete questions, which are never returned though. May return
  # less questions than requested. If the user is logged in, it will
  # prefer questions not yet answered or answered incorrectly often.
  def select_random(question_ids, cnt)
    big_sample = if signed_in?
      # select questions depending on how often they were answered
      # correctly.
      select_random_roulette(question_ids, cnt, current_user)
    else
      select_random_uniform(question_ids, cnt)
    end

    # resolve IDs into questions. Eager load most things required for
    # complete-check and presentation. The complete check is cached
    # after first run. Measurements show there is no downside to
    # including :reviews and :parent, even if they are not required.
    big_sample = Question.where(id: big_sample)
                  .includes(:answers, :reviews, :parent, :hints)

    samp = []
    big_sample.each do |s|
      samp << s if s.complete?
      # avoid completeness check if we have enough questions already
      break if samp.size == cnt
    end

    # warn if it’s possible that user desire could have been fulfilled.
    # If there are a lot of incomplete questions this may not be true,
    # so only increase INCREASE_FACTOR if you get this warning often and
    # if you question corpus is large enough.
    if samp.size < cnt && question_ids.size > cnt
      logger.warn "Got less questions than requested. Try increasing INCREASE_FACTOR."
      logger.warn "Available: #{question_ids*", "}"
      logger.warn "Selected: #{samp*", "}"
    end

    #~ dbgsamp = samp.map { |s| s.id }.join('  ')
    #~ dbgqs = qs.map { |s| s.id }.join('  ')
    #~ logger.debug "RANDOM DEBUG: cnt=#{cnt} samp=#{dbgsamp} quests=#{dbgqs}  signed_in=#{signed_in?}"

    samp
  end


  # roulette wheel selection for questions, depending on correct answer
  # ratio by user. Implementation by Jakub Hampl. Returns array of
  # question_ids.
  # http://stackoverflow.com/a/5243844/1684530
  def select_random_roulette(question_ids, n, user)
    logger.debug "### roulette selection"
    probs = wrong_ratio_for(question_ids, user)

    selected = []
    (n*INCREASE_FACTOR).to_i.times do
      break if probs.empty?
      break if selected.size == n

      r, inc = rand * probs.sum, 0
      question_ids.each_index do |i|
        if r < (inc += probs[i])
          selected << question_ids[i]
          # make selection not pick sample twice
          question_ids.delete_at i
          probs.delete_at i
          break
        end
      end
    end

    return selected
  end

  def select_random_uniform(question_ids, n)
    logger.debug "### uniform selection"
    question_ids.sample(n*INCREASE_FACTOR)
  end
end
