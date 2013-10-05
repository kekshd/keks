require "./app/models/user.rb"

class AddReviewerToUsers < ActiveRecord::Migration
  def up
    add_column :users, :reviewer, :boolean, :default => false
    change_column_default :users, :admin, false

    # update admin column to true/false instead of 0/1 format
    User.all.each do |u|
      u.admin = u.admin? ? true : false
      u.save
    end
    User.where(admin: 1).update_all(admin: true)
  end

  def down
    remove_column :users, :reviewer, :boolean, :default => false
  end
end
