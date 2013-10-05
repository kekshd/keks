require "./app/models/question.rb"

class AddContentChangedAtToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :content_changed_at, :datetime
    Question.reset_column_information

    Question.update_all({:content_changed_at => Time.now})
  end
end
