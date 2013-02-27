class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.references :parent, :polymorphic => true
      t.timestamps
    end
  end
end
