class AddIdentToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :ident, :string
  end
end
