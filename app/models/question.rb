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

  has_many :reviews, dependent: :destroy, order: 'updated_at DESC', inverse_of: :question
  has_many :answers, dependent: :destroy, inverse_of: :question
  has_many :hints, order: 'sort_hint ASC', dependent: :destroy, inverse_of: :question
  has_and_belongs_to_many :starred_by, :class_name => :User, :join_table => :starred
  before_destroy do |q|
    sql =  ["DELETE FROM starred WHERE question_id = ?", q.id]
    connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, sql))
  end

  # simply remove, no deconstruction and the like
  has_many :stats, dependent: :delete_all, inverse_of: :question

  # i.e. this question has one parent, either Answer or Category
  belongs_to :parent, :polymorphic => true

  before_create do
    self.content_changed_at = Time.now
  end

  before_save do
    Rails.cache.write(:questions_last_update, Time.now)
    up = parent_type_changed? || parent_id_changed? || text_changed?
    up ||= study_path_changed? || difficulty_changed?
    self.content_changed_at = Time.now if up
  end

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
    s << (parent ? parent.trace_to_root : "[[no parent]]")
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

  include DotTools

  def dot(active = false)
    id = ident.gsub('"', '')

    # strike text through using a strike through UTF8 character
    id = id.scan(/./).join('̶')+'̶' if !complete?

    txt = 'F: ' + id
    bg = active ? ', style=filled, fillcolor = "#AAC6D2"' : ''
    %(#{dot_id} [label="#{txt}"#{bg}, shape=box];\n)
  end

  def dot_id
    'q' + dot_clean(ident)
  end

  def dot_hints
    return '' if hints.none?

    hintTexts = hints.map { |h| h.dot_text }.join("\\n")

    d = ""
    d << %(HINT#{dot_id} [label="#{hintTexts}", shape=none];)
    d << "#{dot_id} -> HINT#{dot_id};"
    d << "{ rank=same; #{dot_id} HINT#{dot_id} };\n"
    d
  end

  def dot_region(may_omit = false)
    d = ''

    d << dot(true)
    d << dot_region_parent(may_omit)

    answers.each do |a|
      d << dot_link_to(self, a)
      d << dot_link_to(a, a.questions)
      d << dot_link_to(a, a.categories)
    end

    d << dot_hints

    d
  end

  private

  def dot_region_parent(may_omit)
    return "" unless parent

    d = parent.dot

    # link to ourselves
    d << "#{parent.dot_id} -> #{dot_id};\n"

    # link parent to our siblings, i.e. other questions
    d << dot_region_siblings(may_omit)

    # link to other children of the parents. Those are the same level
    # as the sibling questions above.
    d << dot_link_to(parent, parent.categories) if parent.respond_to?(:categories)

    d << dot_region_parent_of_parent

    d
  end

  # renders dot that shows how our parent fits into the whole tree, i.e.
  # it renders our parent’s parents.
  def dot_region_parent_of_parent
    return dot_link_from(parent.answers, parent) if parent.is_a?(Category)
    return "" unless parent.is_a?(Answer)

    d = dot_link_from(parent.question, parent)

    parent.question.subquestions.each do |qq|
      next if qq == self
      d << dot_link_to(parent.question, qq)
    end

    d
  end

  # renders dot code for the siblings of this question. If may omit is
  # set to true, it may only include some of the siblings. Otherwise
  # all will be shown.
  def dot_region_siblings(may_omit)
    return "" unless parent.respond_to?(:questions)

    limit = 6
    qs = parent.questions.includes(:answers, :parent).limit(may_omit ? limit : -1)
    qs.reject! { |q| q == self }

    d = dot_link_to(parent, qs)
    remaining = may_omit ? parent.questions.size - limit - 1 : 0

    return d if remaining <= 0

    # this is not always correct, as above may include the current
    # question. Thus, only left-1 questions would be left.
    d << %(#{dot_id}_hidden_siblings [label="+#{left} weitere Fragen", shape=none];)
    d << %(#{parent.dot_id} -> #{dot_id}_hidden_siblings;\n)
    d
  end


  def is_complete_helper
    key = ["question_complete_helper"]
    key << last_admin_or_reviewer_change
    key << id
    key = key.join("__")

    Rails.cache.fetch(key) {
      is_complete_helper_real
    }
  end

  def is_complete_helper_real
    return false, "nicht freigegeben" if !released?
    return false, "keine Antworten" if answers.size == 0
    return false, "keine richtige Antwort" if answers.none? { |a| a.correct? }
    return false, "Reviewer sagt „nicht okay“" if reviews.any? { |a| !a.okay? }
    # allow questions to be released regardless of # of reviews
    #return false, "nicht genug Reviews" if reviews.size < REVIEW_MIN_REQUIRED_REVIEWS
    return false, "Eltern-Frage nicht freigegeben" if parent_type == "Answer" && !parent.question.released?
    return false, "Eltern-Kategorie nicht freigegeben" if parent_type == "Category" && !parent.released?

    # skip checks if this question is valid for all study paths
    return true, "" if study_path == 1
    # ensure the study path doesn’t change in between to avoid unreachable questions
    psp = parent.question.study_path if parent.is_a?(Answer)
    if psp && psp != study_path && study_path != 1 && psp != 1
      return false, "Unerreichbar, da das Elter eine andere Zielgruppe als diese Frage hat."
    end
    return true, ""
  end
end
