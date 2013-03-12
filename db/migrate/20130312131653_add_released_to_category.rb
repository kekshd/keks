class AddReleasedToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :released, :boolean
  end
end
