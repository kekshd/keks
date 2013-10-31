class Stat < ActiveRecord::Base
  default_scope where("stats.created_at > ?", 30.days.ago)

  attr_accessible :selected_answers, :question_id, :user_id, :correct, :skipped, :time_taken

  class StringSplitter
    def load(text)
      return [] unless text
      text.split(" ").map { |x| x.to_i }
    end

    def dump(text)
      raise "selected_answers must be an array" unless text.is_a?(Array)
      text.map { |t| t.to_i }.join(" ")
    end
  end

  serialize :selected_answers, StringSplitter.new

  belongs_to :question, inverse_of: :stats
  belongs_to :user, inverse_of: :stats
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
