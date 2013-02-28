class AddTyeToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :type, :string
  end
end
