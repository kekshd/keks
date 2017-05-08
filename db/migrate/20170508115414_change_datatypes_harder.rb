class ChangeDatatypesHarder < ActiveRecord::Migration
  def up
    change_column :perfs, :load_time, :integer, :limit => 8
    change_column :perfs, :agent, :text, :limit => nil
    change_column :perfs, :url, :text, :limit => nil
  end

  def down
    change_column :perfs, :load_time, :bigint
  end
end
