class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nick
      t.string :mail
      t.string :password_digest

      t.timestamps
    end
  end
end
