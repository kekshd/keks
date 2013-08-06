# encoding: utf-8

class Question < ActiveRecord::Base
  attr_accessible :text, :answers, :ident, :released
  validates :ident, :uniqueness => true, :presence => true
  validates :text, :presence => true

  attr_accessible :difficulty
  enumerate :difficulty
  validates_inclusion_of :difficulty, in: Difficulty

  attr_accessible :study_path
  enumerate :study_path
  validates_inclusion_of :study_path, in: StudyPath

  has_many :reviews, dependent: :destroy, order: 'updated_at DESC'
  has_many :answers, dependent: :destroy
  has_many :hints, :order => 'sort_hint ASC', :dependent => :destroy
  has_and_belongs_to_many :starred_by, :class_name => :User, :join_table => :starred
  before_destroy do |q|
    sql =  ["DELETE FROM starred WHERE question_id = ?", q.id]
    connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, sql))
  end

  # simply remove, no deconstruction and the like
  has_many :stats, :dependent => :delete_all

  # i.e. this question has one parent, either Answer or Category
  belongs_to :parent, :polymorphic => true

  def subquestions
    answers.map { |a| a.questions }.flatten.uniq
  end

  def subcategories
    answers.map { |a| a.categories }.flatten.uniq
  end

  def correct_ratio_user(user)
    tmp = stats.where(:user_id => user.id, :skipped => false).group(:correct).count
    correct = tmp[true] || 0
    all = (tmp[false] || 0) + correct
    all > 0 ? correct/all.to_f : 0
  end

  # returns the ratio of correct answers. Skipped ones are not counted.
  def correct_ratio
    all = stats.where(:skipped => false).size.to_f
    all > 0 ? correct_count.to_f/all : 0
  end

  def skip_ratio
    all = stats.size.to_f
    all > 0 ? skip_count.to_f/all : 0
  end

  def correct_count
    stats.where(:correct => true, :skipped => false).size
  end

  def skip_count
    stats.where(:skipped => true).size
  end

  def get_parent_category
    parent.is_a?(Category) ? parent : parent.get_parent_category
  end

  def trace_to_root(first = false)
    s = ""
    s << " ← Q:#{ident}" unless first
    s << parent.trace_to_root
    s
  end

  def get_root_categories
    get_parent_category.get_root_categories
  end

  def complete?
    is_complete_helper[0]
  end

  def incomplete_reason
    is_complete_helper[1]
  end

  def matrix_validate?
    return false if answers.size != 1
    a = answers.first.text
    return false if a.scan(%(\\begin{pmatrix})).size != 1
    return false if a.scan(%(\\end{pmatrix})).size != 1
    true
  end

  def matrix_solution
    return nil unless matrix_validate?
    a = self.answers.first.text
    a = a.match(/\\begin\{pmatrix\}(.*)\\end\{pmatrix\}/m)[1]
    rows = a.split(/\s*\\\\\s*/)
    rows = rows.map { |r| r.strip.split(/\s*&\s*/).join(" ") }
    rows.join("  ")
  end

  def dot(active = false)
    id = ident.gsub('"', '')

    # strike text through using a strike through UTF8 character
    id = id.scan(/./).join('̶')+'̶' if !complete?

    txt = 'F: ' + id
    bg = active ? ', style=filled, fillcolor = "#AAC6D2"' : ''
    %(#{dot_id} [label="#{txt}"#{bg}];)
  end

  def dot_id
    'q' + ident.gsub(/[^a-z0-9_]/i, '')
  end

  def dot_hints
    return '' if hints.none?

    hintTexts = []
    hints.each do |h|
      hintTexts << h.dot_text
    end

    d = ""
    d << %(HINT#{dot_id} [label="#{hintTexts.join("\\n")}", shape=none];)
    d << "#{dot_id} -> HINT#{dot_id};"
    d << "{ rank=same; #{dot_id} HINT#{dot_id} };"
    d
  end

  def dot_region
    d = ''

    if parent
      d << parent.dot

      # siblings of the parent
      parent.questions.includes(:answers, :parent).each do |q|
        d << q.dot(q == self)
        d << "#{parent.dot_id} -> #{q.dot_id};"
      end if parent.respond_to?(:questions)

      parent.categories.each do |c|
        d << c.dot
        d << "#{parent.dot_id} -> #{c.dot_id};"
      end if parent.respond_to?(:categories)

      # parent of parent
      if(parent.is_a?(Answer))
        d << parent.question.dot
        d << "#{parent.question.dot_id} -> #{parent.dot_id};"

        parent.question.subquestions.each do |qq|
          next if qq == self
          d << qq.dot
          d << "#{parent.question.dot_id} -> #{qq.dot_id};"
        end
      end

      if(parent.is_a?(Category))
        parent.answers.each do |aa|
          d << aa.dot
          d << "#{aa.dot_id} -> #{parent.dot_id};"
        end
      end
    else
      d << dot(true)
    end

    answers.each do |a|
      d << a.dot
      d << "#{dot_id} -> #{a.dot_id};"

      a.questions.each do |q|
        d << q.dot
        d << "#{a.dot_id} -> #{q.dot_id};"
      end

      a.categories.each do |c|
        d << c.dot
        d << "#{a.dot_id} -> #{c.dot_id};"
      end
    end

    d << dot_hints

    d
  end

  private
  def is_complete_helper
    return false, "nicht freigegeben" if !released?
    return false, "keine Antworten" if answers.size == 0
    return false, "keine richtige Antwort" if answers.none? { |a| a.correct? }
    return false, "Eltern-Frage nicht freigegeben" if parent_type == "Answer" && !parent.question.released?
    return false, "Eltern-Kategorie nicht freigegeben" if parent_type == "Category" && !parent.released?
    psp = parent.question.study_path if parent.is_a?(Answer)
    if psp && psp != study_path && study_path != 1 && psp != 1
      return false, "Unerreichbar, da das Elter eine andere Zielgruppe als diese Frage hat."
    end
    return true, ""
  end
end
