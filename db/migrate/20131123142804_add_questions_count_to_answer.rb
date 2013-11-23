class AddQuestionsCountToAnswer < ActiveRecord::Migration
  def up
    add_column :answers, :questions_count, :integer, null: false, default: 0

    Answer.all.each do |cat|
      Answer.reset_counters(cat.id, :questions)
    end
  end

  def down
    remove_column :answers, :questions_count
  end
end
