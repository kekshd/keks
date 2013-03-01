# encoding: utf-8

class Question < ActiveRecord::Base
  attr_accessible :text, :answers, :ident

  validates :ident, :uniqueness => true, :presence => true
  validates :text, :presence => true

  has_many :answers

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
    a = answers.first
    return false if a.count(%(\begin{pmatrix})) != 1
    return false if a.count(%(\end{pmatrix})) != 1
    true
  end

  private
  def is_complete_helper
    return false, "keine Antworten" if answers.size == 0
    return false, "keine richtige Antwort" if answers.none? { |a| a.correct? }
    return true, ""
  end
end
