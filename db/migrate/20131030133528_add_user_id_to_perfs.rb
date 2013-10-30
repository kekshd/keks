class AddUserIdToPerfs < ActiveRecord::Migration
  def change
    add_column :perfs, :user_id, :integer
  end
end
