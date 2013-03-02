# encoding: utf-8

class Category < ActiveRecord::Base
  attr_accessible :text, :title, :answer_ids, :ident

  validates :ident, :uniqueness => true, :presence => true
  validates :title, :presence => true

  # i.e. this category has many questions and acts as parent to them
  has_many :questions, :as => :parent

  has_and_belongs_to_many :answers

  def Category.root_categories
    Category.all.keep_if { |c| c.is_root? }
  end

  def is_root?
    answers.none?
  end

  def link_text
    "Category #{ident}"
  end

  def dot(active = false)
    txt = 'K: ' + ident.gsub('"', '')
    bg = active ? ', style=filled, fillcolor = "#AAC6D2"' : ''
    %(#{dot_id} [label="#{txt}" #{bg}, shape=#{is_root? ? 'house' : 'folder'}];)
  end

  def dot_id
    'c' + ident.gsub(/[^a-z0-9_]/i, '')
  end

  def dot_region
    d = dot(true)
    questions.each do |q|
      d << q.dot
      d << "#{dot_id} -> #{q.dot_id};"
    end

    answers.each do |a|
      d << a.dot
      d << "#{a.dot_id} -> #{dot_id};"
    end

    d
  end
end
