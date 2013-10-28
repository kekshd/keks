class RemoveTypeAndIdentFromAnswers < ActiveRecord::Migration
  def change
    remove_column :answers, :type, :string
    remove_column :answers, :ident, :string
  end
end
