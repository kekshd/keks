class Answer < ActiveRecord::Base
  attr_reader :correct, :text

  belongs_to :question
  has_many :questions, :as => :parent
  has_many :categories

  def get_parent_category
    return self.question.find_parent_category
  end
end
