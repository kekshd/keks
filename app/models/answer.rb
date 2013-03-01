# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :correct, :text, :ident

  validates :ident, :uniqueness => { :scope => :question_id,
    :message => "Antwort-Idents müssen für eine Frage eindeutig sein" }

  belongs_to :question

  # i.e. this answer has many questions and acts as parent to them
  has_many :questions, :as => :parent


  has_and_belongs_to_many :categories

  def get_parent_category
    return self.question.find_parent_category
  end


  def link_text
    "Antwort #{link_text_short}"
  end

  def link_text_short
    "#{question.ident}/#{ident}"
  end

  def dot
    txt = 'A: ' + ident.gsub('"', '')
    %(#{dot_id} [label="#{txt}", shape=hexagon];)
  end

  def dot_id
    'a' + ident.gsub(/[^a-z0-9_]/i, '') + question.dot_id
  end
end
