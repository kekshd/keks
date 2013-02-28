class AddTitleToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :title, :string
  end
end
