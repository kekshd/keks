# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201302281047123) do

  create_table "answers", :force => true do |t|
    t.string   "text"
    t.boolean  "correct"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ident"
  end

  create_table "answers_categories", :force => true do |t|
    t.integer "answer_id"
    t.integer "category_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
    t.string   "ident"
  end

  create_table "questions", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "text"
    t.string   "ident"
  end

  create_table "users", :force => true do |t|
    t.string   "nick"
    t.string   "mail"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "remember_token"
    t.boolean  "admin"
    t.integer  "study_path"
  end

  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
