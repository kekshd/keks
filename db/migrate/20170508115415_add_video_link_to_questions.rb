class AddVideoLinkToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :video_link, :string, :limit => 255
  end
end
