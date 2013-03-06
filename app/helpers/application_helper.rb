# encoding: utf-8

module ApplicationHelper
  def study_path_ids_from_param
    sp = params[:study_path]
    return [1] if !sp

    unless StudyPath.ids.include?(sp.to_i)
      logger.warn "Tried to access invalid study path id: #{sp}"
      return [1]
    end

    [1, sp]
  end

  def difficulties_from_param
    diff = params[:difficulty] ? params[:difficulty].split("_") : []
    diff = diff.map { |d| d.to_i == 0 ? nil : d.to_i}.compact
    diff.reject! { |d| !Difficulty.ids.include?(d) }
    return diff if diff.any?

    logger.warn "No difficulties given, selecting first"
    return [Difficulty.ids.first]
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
