class CreatePerfs < ActiveRecord::Migration
  def change
    create_table :perfs do |t|
      t.string :agent
      t.string :url
      t.integer :load_time

      t.timestamps
    end
  end
end
