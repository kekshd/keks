# encoding: utf-8

module ApplicationHelper
  def url_for(options = nil)
    if Hash === options && Rails.env.production?
      options[:protocol] = 'https:'
    end
    super(options)
  end

  def redirect_to(options = {}, response_status = {})
    return super(options, response_status) unless Rails.env.production?

    case options
    when String
      if options.start_with?('http://')
        options.sub!(/^http:/, 'https:')
      elsif options =~ /^\w+:\/\//i
      else
        options = request.protocol.sub('http', 'https') + request.host_with_port + options
      end
    when :back
    when Proc
    else
      o = options.merge({:protocol => 'https:'}) rescue options
      url_for(o).sub(/^http:/, 'https:')
    end

    super(options, response_status)
  end


  def study_path_ids_from_param
    sp = params[:study_path]
    return [1] if !sp

    unless StudyPath.ids.include?(sp.to_i)
      logger.warn "Tried to access invalid study path id: #{sp}"
      return [1]
    end

    [1, sp.to_i].uniq
  end

  def difficulties_from_param
    diff = params[:difficulty] ? params[:difficulty].split("_") : []
    diff = diff.map { |d| d.to_i == 0 ? nil : d.to_i}.compact
    diff.reject! { |d| !Difficulty.ids.include?(d) }
    return diff if diff.any?

    logger.warn "No difficulties given, selecting first"
    return [Difficulty.ids.first]
  end

  def reject_unsuitable_questions!(qs)
    diff = difficulties_from_param
    sp = study_path_ids_from_param
    qs.reject! do |q|
      !diff.include?(q.difficulty) || !sp.include?(q.study_path) || !q.complete?
    end
  end

  def get_question_sample(qs, cnt)
    samp = nil
    if signed_in?
      # select questions depending on how often they were answered
      # correctly.
      samp = roulette(qs, current_user, cnt)
    else
      # uniform distribution
      samp = qs.sample(cnt)
    end
    #~ dbgsamp = samp.map { |s| s.id }.join('  ')
    #~ dbgqs = qs.map { |s| s.id }.join('  ')
    #~ logger.debug "RANDOM DEBUG: cnt=#{cnt} samp=#{dbgsamp} quests=#{dbgqs}  signed_in=#{signed_in?}"

    samp
  end

  def get_subquestion_for_answer(a, max_depth)
    sq = max_depth > 0 ? a.get_all_subquestions : []
    reject_unsuitable_questions!(sq)

    if sq.size > 0
      sq = get_question_sample(sq, 1)
      sq = json_for_question(sq.first, max_depth - 1)
    else
      sq = nil
    end
    sq
  end

  # roulette wheel selection for questions, depending on correct answer
  # ratio by user. Implementation by Jakub Hampl.
  # http://stackoverflow.com/a/5243844/1684530
  def roulette(questions, user, n)
    # calculate ratio for each question how often it was answered in-
    # correctly by the user. Effectively, all the code does is:
    #   probs = questions.map { |q| [1 - q.correct_ratio_user(user), 0.1].max }
    # but a lot faster.
    tmp = Stat.unscoped.where(:user_id => user.id, :skipped => false)
    correct = tmp.where(:correct => true).group(:question_id).size
    wrong = tmp.where(:correct => false).group(:question_id).size

    probs = questions.map do |q|
      c = correct[q.id] || 0
      w = wrong[q.id] || 0
      cw = c+w
      [cw == 0 ? 1 : w/(c+w).to_f, 0.1].max
    end


    selected = []
    n.times do
      break if probs.empty?
      r, inc = rand * probs.sum, 0
      questions.each_index do |i|
        if r < (inc += probs[i])
          selected << questions[i]
          # make selection not pick sample twice
          questions.delete_at i
          probs.delete_at i
          break
        end
      end
    end
    return selected
  end
end
