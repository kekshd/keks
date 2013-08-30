class MoreIndexes < ActiveRecord::Migration
  def change
    add_index :stats, :user_id
    add_index :reviews, :question_id
    add_index :starred, [:user_id, :question_id]



    #~　add_index :questions, :id
  end
end
