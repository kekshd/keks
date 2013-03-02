# encoding: utf-8

class Question < ActiveRecord::Base
  attr_accessible :text, :answers, :ident
  validates :ident, :uniqueness => true, :presence => true
  validates :text, :presence => true

  attr_accessible :difficulty
  enumerate :difficulty
  validates_inclusion_of :difficulty, in: Difficulty

  attr_accessible :study_path
  enumerate :study_path
  validates_inclusion_of :study_path, in: StudyPath

  has_many :answers, :dependent => :destroy
  has_many :hints, :order => 'sort_hint ASC', :dependent => :destroy

  # i.e. this question has one parent, either Answer or Category
  belongs_to :parent, :polymorphic => true

  def get_parent_category
    parent.is_a?(Category) ? parent : parent.get_parent_category
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
    return false if a.count(%(\begin{pmatrix})) != 1
    return false if a.count(%(\end{pmatrix})) != 1
    true
  end

  def dot(active = false)
    txt = 'F: ' + ident.gsub('"', '')
    bg = active ? ', style=filled, fillcolor = "#AAC6D2"' : ''
    %(#{dot_id} [label="#{txt}"#{bg}];)
  end

  def dot_id
    'q' + ident.gsub(/[^a-z0-9_]/i, '')
  end

  def dot_region
    d = ''

    if parent
      d << parent.dot

      parent.questions.each do |q|
        d << q.dot(q == self)
        d << "#{parent.dot_id} -> #{q.dot_id};"
      end if parent.respond_to?(:questions)

      parent.categories.each do |c|
        d << c.dot
        d << "#{parent.dot_id} -> #{c.dot_id};"
      end if parent.respond_to?(:categories)
    else
      d << dot(true)
    end

    answers.each do |a|
      d << a.dot
      d << "#{dot_id} -> #{a.dot_id};"
    end

    hint_ids = []
    hints.each do |h|
      hint_ids << h.dot
      d << h.dot
      d << "#{dot_id} -> #{h.dot_id};"
    end

    d << "{ rank=same; #{dot_id} #{hint_ids.join} };"

    d
  end

  private
  def is_complete_helper
    return false, "keine Antworten" if answers.size == 0
    return false, "keine richtige Antwort" if answers.none? { |a| a.correct? }
    return true, ""
  end
end
