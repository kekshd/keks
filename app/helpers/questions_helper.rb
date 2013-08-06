module QuestionsHelper
  def link_to_parent(q)
    return "Kein Eltern-Elem." if q.nil? || q.parent.nil?
    if q.parent.is_a?(Category)
      link_to(q.parent.link_text, q.parent)
    else
      link_to(q.parent.link_text, q.parent.question)
    end
  end

  def get_question_stat_counts(questions = nil)
    counts = {}
    if questions
      questions = [questions] unless questions.is_a?(Array)
      quest_ids = questions.map { |q| q.is_a?(Question) ? q.id : q.to_i }

      counts[:all] = Stat.unscoped.where(question_id: quest_ids).group(:question_id).count
      counts[:skip] = Stat.unscoped.where(question_id: quest_ids, skipped: true).group(:question_id).count
      counts[:correct] = Stat.unscoped.where(question_id: quest_ids, correct: true).group(:question_id).count
    else
      counts[:all] = Stat.unscoped.group(:question_id).count
      counts[:skip] = Stat.unscoped.where(skipped: true).group(:question_id).count
      counts[:correct] = Stat.unscoped.where(correct: true).group(:question_id).count
    end
    counts
  end

  def get_answer_stat_counts(question)
    counts = {}
    stats = Stat.unscoped.where(question_id: question.id).pluck(:selected_answers)
    stats.flatten.group_by { |i| i}.each { |answ_id, v| counts[answ_id] = v.size }
    counts[:all] = counts.values.reduce(:+)
    counts
  end
end
