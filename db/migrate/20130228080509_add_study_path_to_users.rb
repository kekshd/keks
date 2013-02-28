class AddStudyPathToUsers < ActiveRecord::Migration
  def change
    add_column :users, :study_path, :integer
  end
end
