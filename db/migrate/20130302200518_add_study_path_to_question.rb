class AddStudyPathToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :study_path, :integer
  end
end
