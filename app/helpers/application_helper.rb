# encoding: utf-8

module ApplicationHelper
  def study_path_ids_from_param
    sp = params[:study_path]
    return [1] if !sp

    unless StudyPath.ids.include?(sp.to_i)
      logger.warn "Tried to access invalid study path id: #{sp}"
      return [1]
    end

    [1, sp.to_i]
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
      !q.complete? || !diff.include?(q.difficulty) || !sp.include?(q.study_path)
    end
  end

  def get_question_sample(qs, cnt)
    if signed_in?
      # select questions depending on how often they were answered
      # correctly.
      roulette(qs, current_user, cnt)
    else
      # uniform distribution
      qs.sample(cnt)
    end
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
    probs = questions.map { |q| [1 - q.correct_ratio_user(user), 0.1].max }

    selected = []

    n.times do
      break if probs.empty?
      r, inc = rand * probs.max, 0
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
