class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :questions, :parent_id
    add_index :answers, :question_id
  end
end
