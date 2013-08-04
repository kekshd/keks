# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :correct, :text, :ident

  validates :ident, :uniqueness => { :scope => :question_id,
    :message => "Antwort-Idents müssen für eine Frage eindeutig sein" }

  belongs_to :question

  # i.e. this answer has many questions and acts as parent to them
  has_many :questions, :as => :parent

  has_many :stats

  has_and_belongs_to_many :categories

  def check_ratio
    return -1 if question.matrix_validate?
    all = question.stats.pluck(:selected_answers)
    me = all - [id]
    return 1-me.size.to_f/all.size.to_f
  end

  def get_parent_category
    return self.question.find_parent_category
  end

  def get_all_subquestions
    questions + categories.map { |c| c.questions }.flatten
  end

  def get_all_subquestion_ids
    get_all_subquestions.map { |q| q.id }
  end


  def link_text
    "Antwort #{link_text_short}"
  end

  def link_text_short
    "#{question.ident}/#{ident}"
  end

  def dot
    txt = 'A: ' + ident.gsub('"', '')
    %(#{dot_id} [label="#{txt}", shape=hexagon, color=#{correct? ? 'green' : 'red'}];)
  end

  def dot_id
    'a' + ident.gsub(/[^a-z0-9_]/i, '') + question.dot_id
  end
end
