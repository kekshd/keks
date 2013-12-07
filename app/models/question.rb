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
  belongs_to :parent, polymorphic: true, counter_cache: true

  # returns all questions that have a parent category. If a categroy or
  # its id is given, only questions with that exact category are
  # returned.
  scope :with_parent_cat, (lambda do |cat = nil|
    cond = { parent_type: "Category" }
    cond[:parent_id] = cat.is_a?(Category) ? cat.id : cat if cat
    { conditions: cond }
  end)

  scope :siblings, (lambda do |quest|
    where(parent_type: quest.parent_type, parent_id: quest.parent_id).where(["id <> ?", quest.id])
  end)

  def siblings
    Question.siblings(self)
  end

  searchable do
    text :text,  stored: true
    text :ident, stored: true

    text :answers, stored: true do answers.map(&:text) end
    text :reviews, stored: true do reviews.map(&:comment) end
    text :hints,   stored: true do hints.map(&:text) end

    text :parent, stored: true do
      next "" unless parent
      p = parent
      r = p.text
      r << " " + p.title if p.respond_to?(:title)
      r << " " + p.ident if p.respond_to?(:ident)
    end
  end

  before_save do
    Rails.cache.write(:questions_last_update, Time.now)
    up = parent_type_changed? || parent_id_changed? || text_changed?
    up ||= study_path_changed? || difficulty_changed?
    self.content_changed_at = Time.now if up || new_record?
  end

  def subquestions
    Question.where(parent_type: Answer, parent_id: answers)
  end

  def subcategories
    answers.map(&:categories).flatten.uniq
  end

  include StatTools

  def get_parent_category
    return nil if parent.nil?
    parent.is_a?(Category) ? parent : parent.get_parent_category
  end

  def trace_to_root(first = false)
    s = ""
    s << " ← Q:#{ident}" unless first
    s << (parent ? parent.trace_to_root : "[[no parent]]")
  end

  def get_root_categories
    pc = get_parent_category
    return [] if pc.nil?
    pc.get_root_categories
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

  def parent_html_ref
    "#{parent_type}_#{parent_id}"
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

    hintTexts = hints.map(&:dot_text).join("\\n")

    d = ""
    d << %(HINT#{dot_id} [label="#{hintTexts}", shape=none];)
    d << "#{dot_id} -> HINT#{dot_id};"
    d << "{ rank=same; #{dot_id} HINT#{dot_id} };\n"
  end

  def dot_region(may_omit = false)
    d = ''

    d << dot(true)
    d << dot_region_parent(may_omit)

    answers.each do |a|
      d << dot_link_to(self, a)
      d << dot_link_to(a, [a.questions, a.categories])
    end

    d << dot_hints
  end

  def has_bad_reviews?
    key = "quests_with_bad_reviews__#{Review.last_update}"
    q_with_bad_reviews = Rails.cache.fetch(key) do
      Review.where(okay: false).pluck(:question_id)
    end
    q_with_bad_reviews.include?(id)
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
  end

  # renders dot that shows how our parent fits into the whole tree, i.e.
  # it renders our parent’s parents.
  def dot_region_parent_of_parent
    case parent
    when Category
      dot_link_from(parent.answers, parent)
    when Answer
      d = dot_link_from(parent.question, parent)
      d << dot_link_to(parent.question, siblings)
    end
  end

  # renders dot code for the siblings of this question. If may omit is
  # set to true, it may only include some of the siblings. Otherwise
  # all will be shown.
  def dot_region_siblings(may_omit)
    return "" unless parent.respond_to?(:questions)

    limit = may_omit ? 6 : -1
    qs = siblings.includes(:answers, :parent).limit(limit).to_a

    d = dot_link_to(parent, qs)
    remaining = parent.questions.size - limit - 1

    return d if remaining <= 0 or !may_omit

    # this is not always correct, as above may include the current
    # question. Thus, only left-1 questions would be left.
    d << %(#{dot_id}_hidden_siblings [label="+#{remaining} weitere Fragen", shape=none];)
    d << %(#{parent.dot_id} -> #{dot_id}_hidden_siblings;\n)
  end


  def is_complete_helper
    key = "question_complete_helper__#{last_admin_or_reviewer_change}__#{id}"

    Rails.cache.fetch(key) {
      is_complete_helper_real
    }
  end

  def is_complete_helper_real
    return false, "nicht freigegeben" if !released?
    return false, "keine Antworten" if answers.size == 0
    # note: matrix_validate? is false if there is more than one answers.
    # Thus it’s enough to ensure that the first answer is correct rather
    # than all of them. This avoids an additional database query.
    return false, "Matrix-Fragen müssen genau eine Antwort haben, welche richtig sein muss" if matrix_validate? && !answers.first.correct?
    return false, "Reviewer sagt „nicht okay“" if has_bad_reviews?
    return false, "Elter nicht freigegeben" if parent && !parent.released?
    return false, "Unerreichbar, da das Elter eine andere Zielgruppe als diese Frage hat." unless study_path_reachable?
    return true, ""
  end

  # returns false if the direct parent element has an incompatible study
  # path to ours. I.e. returns false if this question is unreachable due
  # to study path mismatches.
  def study_path_reachable?
    # skip checks if this question is valid for all study paths
    return true if study_path == 1
    # categories don’t have a study path. If the category is not a root
    # one, it is be possible to create unreachable questions like this:
    # RootCat → Q w/ study path 1 → Cat → Q w/ study path 2
    # This isn’t checked as a speed trade off: it would require tracing
    # every possible way to root and checking each for study paths.
    return true if parent_type != "Answer"
    psp = parent.question.study_path
    return psp == study_path || psp == 1
  end
end
