class AddIsRootToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :is_root, :boolean
  end
end
