class AddCorrectToStats < ActiveRecord::Migration
  def change
    add_column :stats, :correct, :boolean
  end
end
