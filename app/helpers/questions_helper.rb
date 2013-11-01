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
    filter = {}

    if questions
      questions = [questions] unless questions.is_a?(Array)
      quest_ids = questions.map { |q| q.is_a?(Question) ? q.id : q.to_i }
      filter = {question_id: quest_ids}
    end

    s = Stat.unscoped.where(filter)

    {
      all:     s.group(:question_id).count,
      skip:    s.where(skipped: true).group(:question_id).count,
      correct: s.where(correct: true).group(:question_id).count
    }
  end

  def get_answer_stat_counts(question)
    counts = {}
    stats = Stat.unscoped.where(question_id: question.id).pluck(:selected_answers)
    stats.flatten.group_by { |i| i}.each { |answ_id, v| counts[answ_id] = v.size }
    counts[:all] = counts.values.reduce(:+)
    counts
  end
end
