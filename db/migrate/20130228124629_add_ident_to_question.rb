class AddIdentToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :ident, :string
  end
end
