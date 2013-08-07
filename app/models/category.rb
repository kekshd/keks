# encoding: utf-8

class Category < ActiveRecord::Base
  attr_accessible :text, :title, :answer_ids, :ident, :released, :is_root

  validates :ident, :uniqueness => true, :presence => true
  validates :title, :presence => true

  # i.e. this category has many questions and acts as parent to them
  has_many :questions, :as => :parent

  has_and_belongs_to_many :answers

  def Category.root_categories
    Category.all.keep_if { |c| c.is_root? && c.released? }
  end

  def get_root_categories
    return [self] if self.is_root?
    parent_cats = answers.includes(:question).map { |a| a.get_parent_category }.uniq
    parent_cats.map { |c| c.get_root_categories }.flatten.uniq
  end

  def title_split
    s = title.split(":", 2)
    return s.size == 2 ? s : ["", title]
  end

  def link_text
    "Category #{ident}"
  end

  def trace_to_root(first = false)
    s = ""
    s << " ← C:#{title}" unless first
    return s if is_root?
    s << "\0open\0"
    answers.each do |a|
      s << a.trace_to_root
      s << "\0newline\0"
    end
    s << "\0close\0"
    s
  end

  def dot(active = false)
    id = ident.gsub('"', '')
    id = id.scan(/./).join('̶')+'̶' if !released?

    txt = 'K: ' + id
    bg = active ? ', style=filled, fillcolor = "#AAC6D2"' : ''
    %(#{dot_id} [label="#{txt}" #{bg}, shape=#{is_root? ? 'house' : 'folder'}];\n)
  end

  def dot_id
    'c' + ident.gsub(/[^a-z0-9_]/i, '')
  end

  def dot_region
    d = dot(true)
    questions.each do |q|
      d << q.dot
      d << "#{dot_id} -> #{q.dot_id};\n"

      q.subquestions.each do |qq|
        d << qq.dot
        d << "#{q.dot_id} -> #{qq.dot_id};\n"
      end

      q.subcategories.each do |c|
        d << c.dot
        d << "#{q.dot_id} -> #{c.dot_id};\n"
      end
    end

    answers.each do |a|
      d << a.dot
      d << "#{a.dot_id} -> #{dot_id};\n"

      d << a.question.dot
      d << "#{a.question.dot_id} -> #{a.dot_id};\n"
    end

    d
  end
end
