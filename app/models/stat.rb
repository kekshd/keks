class Stat < ActiveRecord::Base
  default_scope where("stats.created_at > ?", 30.days.ago)

  attr_protected :selected_answers, :question_id, :user_id, :correct

  serialize :selected_answers, Array

  belongs_to :question
  belongs_to :user
  #~ belongs_to :answer

  def anonymous?
    user_id == -1
  end

  def correct?
    correct && !skipped?
  end

  def wrong?
    !correct && !skipped?
  end
end
