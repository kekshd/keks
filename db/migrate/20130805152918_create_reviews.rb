class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :question_id
      t.text :comment
      t.boolean :okay
      t.string :votes

      t.timestamps
    end
  end
end
