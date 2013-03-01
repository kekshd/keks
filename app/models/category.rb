# encoding: utf-8

class Category < ActiveRecord::Base
  attr_accessible :text, :title, :answer_ids, :ident

  validates :ident, :uniqueness => true

  # i.e. this category has many questions and acts as parent to them
  has_many :questions, :as => :parent

  has_and_belongs_to_many :answers

  def Category.root_categories
    Category.all.keep_if { |c| c.is_root? }
  end

  def is_root?
    Answer.any? { |a| a.categories.include?(self) }
  end

  def link_text
    "Category #{ident}"
  end
end
