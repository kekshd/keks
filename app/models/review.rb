class Review < ActiveRecord::Base
  attr_accessible :comment, :okay, :votes

  belongs_to :question
  belongs_to :user

  serialize :votes

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.votes || {})[:#{method_name}] || 0.5
        end
        def #{method_name}=(value)
          self.votes ||= {}
          self.votes[:#{method_name}] = value.to_f
        end
        attr_accessible :#{method_name}
      "
    end
  end

  serialized_attr_accessor :difficulty, :awesomeness, :gfoad
  validates :difficulty, :inclusion => 0..10



  validates_uniqueness_of :question_id, :scope => :user_id

  belongs_to :user
  belongs_to :question

  def question_updated_since?
    return false if self.new_record?
    updated_at < question.content_changed_at
  end
end
