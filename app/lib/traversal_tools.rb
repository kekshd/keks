# encoding: utf-8

module TraversalTools
  def trace_to_root(first = false)
    s = ""
    desc = ident rescue id
    s << " ← #{self.class.name.first}:#{desc}" unless first
    s << (parent ? parent.trace_to_root : "[[no parent]]")
  end

  def get_parent_category
    return self if self.is_a?(Category)
    return nil if parent.nil?
    parent.get_parent_category
  end

  def get_root_categories
    get_parent_category.get_root_categories rescue []
  end
end
