class CreateTextStorage < ActiveRecord::Migration
  def change
    create_table :text_storage do |t|
      t.string :ident, :unique => true
      t.text :value
      t.timestamps
    end
  end
end
