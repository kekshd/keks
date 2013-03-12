class AddReleasedToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :released, :boolean
  end
end
