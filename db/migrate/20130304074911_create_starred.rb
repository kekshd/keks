class CreateStarred < ActiveRecord::Migration
  def self.up
    create_table :starred, :id => false do |t|
      t.integer :user_id
      t.integer :question_id
    end
  end

  def self.down
    drop_table :starred
  end
end
