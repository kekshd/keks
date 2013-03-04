class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :user_id
      t.integer :question_id
      t.integer :answer_id

      t.timestamps
    end
  end
end
