# encoding: utf-8

class Question < ActiveRecord::Base
  attr_accessible :text, :answers

  validates :ident, :uniqueness => true

  has_many :answers

  # i.e. this question has one parent, either Answer or Category
  belongs_to :parent, :polymorphic => true

  def get_parent_category
    parent.is_a?(Category) ? parent : parent.get_parent_category
  end

end
