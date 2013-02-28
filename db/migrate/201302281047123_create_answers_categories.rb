class CreateAnswersCategories < ActiveRecord::Migration
  def change
    create_table :answers_categories do |t|
      t.integer :answer_id
      t.integer :category_id
    end
  end
end
