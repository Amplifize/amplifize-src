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

ActiveRecord::Schema.define(:version => 20130603064141) do

  create_table "comments", :force => true do |t|
    t.integer  "share_id"
    t.integer  "user_id"
    t.text     "comment_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consumer_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",       :limit => 30
    t.string   "token",      :limit => 1024
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feed_statuses", :force => true do |t|
    t.integer  "feed_id"
    t.string   "url"
    t.integer  "status_code"
    t.integer  "response_code"
    t.text     "message"
    t.datetime "update_time"
  end

  add_index "feed_statuses", ["feed_id"], :name => "index_feed_statuses_on_feed_id"

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_update_date"
    t.integer  "feed_type",        :default => 1
    t.integer  "status",           :default => 1
    t.datetime "next_update_at"
    t.text     "description"
    t.text     "site_url"
  end

  add_index "feeds", ["url"], :name => "index_feeds_on_url", :unique => true

  create_table "feeds_users", :id => false, :force => true do |t|
    t.integer  "feed_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feeds_users", ["feed_id", "user_id"], :name => "index_feeds_users_on_feed_id_and_user_id", :unique => true

  create_table "follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follows"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["user_id"], :name => "follows_user_id_fk"

  create_table "invites", :force => true do |t|
    t.string   "uid"
    t.string   "email"
    t.text     "message"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invites", ["uid"], :name => "index_invites_on_uid", :unique => true

  create_table "post_users", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.integer  "read_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_users", ["post_id", "user_id"], :name => "index_post_users_on_post_id_and_user_id", :unique => true
  add_index "post_users", ["user_id"], :name => "post_users_user_id_fk"

  create_table "posts", :force => true do |t|
    t.string   "uid"
    t.string   "title"
    t.string   "url"
    t.datetime "published_at"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feed_id"
    t.text     "author"
  end

  add_index "posts", ["feed_id", "uid"], :name => "index_posts_on_feed_id_and_uid", :unique => true
  add_index "posts", ["feed_id"], :name => "posts_feed_id_fk"

  create_table "share_users", :force => true do |t|
    t.integer  "share_id"
    t.integer  "user_id"
    t.integer  "read_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_update_at"
    t.datetime "last_viewed_at"
  end

  create_table "shares", :force => true do |t|
    t.text     "summary"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "feed_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
    t.string   "single_access_token",                 :null => false
    t.string   "perishable_token",    :default => "", :null => false
    t.datetime "last_request_at"
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  add_foreign_key "follows", "users", :name => "follows_user_id_fk"

  add_foreign_key "post_users", "posts", :name => "post_users_post_id_fk"
  add_foreign_key "post_users", "users", :name => "post_users_user_id_fk"

  add_foreign_key "posts", "feeds", :name => "posts_feed_id_fk"

end
