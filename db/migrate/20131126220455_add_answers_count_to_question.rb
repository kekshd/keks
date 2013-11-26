class AddAnswersCountToQuestion < ActiveRecord::Migration
  def up
    add_column :questions, :answers_count, :integer, null: false, default: 0

    Question.all.each do |q|
      Question.reset_counters(q.id, :answers)
    end
  end

  def down
    remove_column :questions, :answers_count
  end
end
