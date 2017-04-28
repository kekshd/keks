class ChangePerfsDataTypesForPostgres < ActiveRecord::Migration
  def up
    change_column :perfs, :url, :text, :limit => nil
    change_column :perfs, :load_time, :bigint
    change_column :perfs, :agent, :text, :limit => nil
  end

  def down
    change_column :perfs, :url, :string
    change_column :perfs, :load_time, :integer
    change_column :perfs, :agent, :string
  end
end
