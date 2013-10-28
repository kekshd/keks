# encoding: utf-8

module DotTools
  # creates a link from A → B, assuming B is not yet known (i.e. its
  # dot representation will be inserted). Both A and B may be arrays,
  # in that case links will be made between each pair.
  def dot_link_to(a, b)
    dot_include([b]) + "   " + dot_link(a, b)
  end

  # creates a link from A → B, assuming A is not yet known (i.e. its
  # dot representation will be inserted). Both A and B may be arrays,
  # in that case links will be made between each pair.
  def dot_link_from(a, b)
    dot_include([a]) + "   " + dot_link(a, b)
  end

  # creates links from A → B, assuming both A and B are already known.
  # Any of the two parameters may be an array, in which case all pairs
  # are linked.
  def dot_link(a, b)
    return a.compact.map { |aa| dot_link(aa, b) }.join("\n") if need_iter?(a)
    return b.compact.map { |bb| dot_link(a, bb) }.join("\n") if need_iter?(b)
    "#{a.dot_id} -> #{b.dot_id};\n"
  end

  # strikes text in dot
  def dot_strike(text)
    text.scan(/./).join('̶')+'̶'
  end

  # returns valid dot_id characters only
  def dot_clean(id)
    id.dup.gsub(/[^a-z0-9_]/i, '')
  end

  def dot_include(arr)
    arr.flatten.compact.map { |a| a.dot }.join("  ")
  end

  private
  def need_iter?(obj)
    obj.is_a?(Array) or obj.is_a?(ActiveRecord::Relation)
  end
end
