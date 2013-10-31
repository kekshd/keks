class AddTimeTakenToStats < ActiveRecord::Migration
  def change
    add_column :stats, :time_taken, :integer
  end
end
