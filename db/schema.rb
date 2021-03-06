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

ActiveRecord::Schema.define(:version => 20170508115414) do

  create_table "answers", :force => true do |t|
    t.text     "text"
    t.boolean  "correct"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "question_id"
    t.integer  "questions_count", :default => 0, :null => false
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "answers_categories", :force => true do |t|
    t.integer "answer_id"
    t.integer "category_id"
  end

  create_table "categories", :force => true do |t|
    t.text     "text"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "title"
    t.string   "ident"
    t.boolean  "is_root"
    t.boolean  "released"
    t.integer  "questions_count", :default => 0, :null => false
  end

  create_table "hints", :force => true do |t|
    t.integer  "sort_hint"
    t.text     "text"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "perfs", :force => true do |t|
    t.text     "agent"
    t.text     "url"
    t.integer  "load_time",  :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "user_id"
  end

  create_table "questions", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.text     "text"
    t.string   "ident"
    t.integer  "difficulty"
    t.integer  "study_path"
    t.boolean  "released"
    t.datetime "content_changed_at"
    t.integer  "answers_count",      :default => 0, :null => false
  end

  add_index "questions", ["parent_id"], :name => "index_questions_on_parent_id"

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.text     "comment"
    t.boolean  "okay"
    t.string   "votes"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "reviews", ["question_id"], :name => "index_reviews_on_question_id"

  create_table "starred", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "question_id"
  end

  add_index "starred", ["user_id", "question_id"], :name => "index_starred_on_user_id_and_question_id"

  create_table "stats", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "correct"
    t.boolean  "skipped",          :default => false
    t.string   "selected_answers"
    t.integer  "time_taken"
  end

  add_index "stats", ["created_at"], :name => "index_stats_on_created_at"
  add_index "stats", ["question_id", "skipped", "correct"], :name => "index_stats_on_question_id_and_skipped_and_correct"
  add_index "stats", ["user_id"], :name => "index_stats_on_user_id"

  create_table "text_storage", :force => true do |t|
    t.string   "ident"
    t.text     "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "nick"
    t.string   "mail"
    t.string   "password_digest"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "remember_token"
    t.boolean  "admin",                  :default => false
    t.integer  "study_path"
    t.text     "enrollment_keys"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "reviewer",               :default => false
  end

  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
