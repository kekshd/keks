class AddIdentToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :ident, :string
  end
end
