class CreateHints < ActiveRecord::Migration
  def change
    create_table :hints do |t|
      t.integer :sort_hint
      t.text :text
      t.integer :question_id
 
      t.timestamps
    end
  end
end
