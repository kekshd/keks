class AddEnrollmentKeysToUser < ActiveRecord::Migration
  def change
    add_column :users, :enrollment_keys, :text
  end
end
