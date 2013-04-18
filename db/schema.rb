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

ActiveRecord::Schema.define(:version => 20130410214608) do

  create_table "bank_accounts", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "user_id"
    t.string   "uri"
    t.string   "bank_name"
    t.string   "owner_name"
    t.string   "last_4_digits"
    t.string   "account_type"
    t.boolean  "is_debitable",  :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "bank_accounts", ["fund_id"], :name => "index_bank_accounts_on_fund_id"
  add_index "bank_accounts", ["user_id"], :name => "index_bank_accounts_on_user_id"

  create_table "funds", :force => true do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "description"
    t.text     "profile"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "funds", ["name"], :name => "index_funds_on_name"
  add_index "funds", ["uid"], :name => "index_funds_on_uid"

  create_table "funds_memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "fund_id"
    t.boolean "is_owner", :default => false
  end

  add_index "funds_memberships", ["fund_id"], :name => "index_funds_memberships_on_fund_id"
  add_index "funds_memberships", ["user_id"], :name => "index_funds_memberships_on_user_id"

  create_table "payments", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "sender_id"
    t.string   "uid"
    t.integer  "amount"
    t.text     "message"
    t.boolean  "is_anonymous", :default => true
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "payments", ["fund_id"], :name => "index_payments_on_fund_id"
  add_index "payments", ["sender_id"], :name => "index_payments_on_sender_id"
  add_index "payments", ["uid"], :name => "index_payments_on_uid"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "uid"
    t.string   "account_uri"
    t.integer  "account_balance"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "street_address"
    t.string   "postal_code"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "image"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["uid"], :name => "index_users_on_uid", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "users_authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "provider_name"
    t.string   "uid"
    t.text     "omniauth_data"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "users_authentications", ["provider"], :name => "index_users_authentications_on_provider"
  add_index "users_authentications", ["uid"], :name => "index_users_authentications_on_uid"
  add_index "users_authentications", ["user_id"], :name => "index_users_authentications_on_user_id"

  create_table "users_payment_cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "card_type"
    t.string   "last_4_digits"
    t.string   "uri"
    t.boolean  "is_default",    :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "users_payment_cards", ["user_id"], :name => "index_users_payment_cards_on_user_id"

end
