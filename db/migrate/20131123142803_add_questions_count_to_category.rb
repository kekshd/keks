class AddQuestionsCountToCategory < ActiveRecord::Migration
  def up
    add_column :categories, :questions_count, :integer, null: false, default: 0

    Category.all.each do |cat|
      Category.reset_counters(cat.id, :questions)
    end
  end

  def down
    remove_column :categories, :questions_count
  end
end
