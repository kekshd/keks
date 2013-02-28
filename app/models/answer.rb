# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :correct, :text, :ident

  validates :ident, :uniqueness => { :scope => :question,
    :message => "Antwort-Idents müssen für eine Frage eindeutig sein" }

  belongs_to :question

  # i.e. this answer has many questions and acts as parent to them
  has_many :questions, :as => :parent


  has_and_belongs_to_many :categories

  def get_parent_category
    return self.question.find_parent_category
  end
end
