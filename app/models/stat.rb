class Stat < ActiveRecord::Base
  attr_protected :answer_id, :question_id, :user_id, :correct

  belongs_to :question
  belongs_to :user
  belongs_to :answer

  def anonymous?
    user_id == -1
  end
end
