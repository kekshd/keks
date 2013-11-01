class AddQuestionIdIndexToStats < ActiveRecord::Migration
  def change
    add_index :stats, [:question_id, :skipped, :correct]
  end
end
