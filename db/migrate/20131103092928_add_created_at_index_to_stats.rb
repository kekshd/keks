class AddCreatedAtIndexToStats < ActiveRecord::Migration
  def change
    add_index :stats, :created_at
  end
end
