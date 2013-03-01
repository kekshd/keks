class AddQuestionIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :question_id, :integer
  end
end
