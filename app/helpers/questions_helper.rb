module QuestionsHelper
  def link_to_parent(q)
    return "Kein Eltern-Elem." if q.nil? || q.parent.nil?
    if q.parent.is_a?(Category)
      link_to(q.parent.link_text, q.parent)
    else
      link_to(q.parent.link_text, q.parent.question)
    end
  end
end
