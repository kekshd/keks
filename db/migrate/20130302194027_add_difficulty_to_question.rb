class AddDifficultyToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :difficulty, :integer
  end
end
