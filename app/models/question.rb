class Question < ActiveRecord::Base
  attr_reader :text

  has_many :answers

  belongs_to :parent, :polymorphic => true

  def get_parent_category
    parent.is_a?(Category) ? parent : parent.get_parent_category
  end

end
