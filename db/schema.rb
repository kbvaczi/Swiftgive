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

ActiveRecord::Schema.define(:version => 20130609132554) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "uid"
    t.string   "balanced_uri"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "street_address"
    t.string   "zipcode"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "avatar"
    t.integer  "current_balance"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "accounts", ["uid"], :name => "index_accounts_on_uid"
  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "accounts_payment_cards", :force => true do |t|
    t.integer  "account_id"
    t.string   "name_on_card"
    t.string   "card_type"
    t.string   "last_4_digits"
    t.string   "balanced_uri"
    t.boolean  "is_default",    :default => false
    t.boolean  "is_active",     :default => true
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "accounts_payment_cards", ["account_id"], :name => "index_accounts_payment_cards_on_account_id"

  create_table "bank_accounts", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "user_id"
    t.string   "balanced_uri"
    t.string   "bank_name"
    t.string   "owner_name"
    t.string   "last_4_digits"
    t.string   "account_type"
    t.boolean  "is_debitable",  :default => false
    t.boolean  "is_active",     :default => true
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
    t.string   "merchant_name"
    t.string   "merchant_date_of_birth"
    t.string   "merchant_phone_number"
    t.string   "merchant_street_address"
    t.string   "merchant_postal_code"
    t.string   "business_name"
    t.string   "business_phone_number"
    t.string   "business_street_address"
    t.string   "business_postal_code"
    t.string   "business_tax_id"
    t.string   "fund_type"
    t.float    "commission_percent"
    t.string   "balanced_uri"
    t.boolean  "is_active",               :default => true
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "give_code",               :default => ""
  end

  add_index "funds", ["fund_type"], :name => "index_funds_on_fund_type"
  add_index "funds", ["name"], :name => "index_funds_on_name"
  add_index "funds", ["uid"], :name => "index_funds_on_uid"

  create_table "funds_memberships", :force => true do |t|
    t.integer "account_id"
    t.integer "fund_id"
    t.boolean "is_owner",   :default => false
  end

  add_index "funds_memberships", ["account_id"], :name => "index_funds_memberships_on_account_id"
  add_index "funds_memberships", ["fund_id"], :name => "index_funds_memberships_on_fund_id"

  create_table "funds_withdraws", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "bank_account_id"
    t.integer  "amount_in_cents"
    t.integer  "commission_in_cents"
    t.integer  "balanced_fee_in_cents"
    t.integer  "amount_to_receiver_in_cents"
    t.string   "status"
    t.string   "uid"
    t.string   "balanced_uri"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "funds_withdraws", ["bank_account_id"], :name => "index_funds_withdraws_on_bank_account_id"
  add_index "funds_withdraws", ["fund_id"], :name => "index_funds_withdraws_on_fund_id"
  add_index "funds_withdraws", ["status"], :name => "index_funds_withdraws_on_status"
  add_index "funds_withdraws", ["uid"], :name => "index_funds_withdraws_on_uid"

  create_table "payments", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "sender_id"
    t.integer  "payment_card_used_id"
    t.text     "message"
    t.boolean  "is_anonymous",         :default => true
    t.integer  "amount"
    t.integer  "commission"
    t.float    "commission_percent"
    t.integer  "balanced_fee"
    t.integer  "amount_to_receiver"
    t.boolean  "is_outstanding",       :default => true
    t.string   "uid"
    t.string   "balanced_uri"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "payments", ["fund_id"], :name => "index_payments_on_fund_id"
  add_index "payments", ["is_outstanding"], :name => "index_payments_on_is_outstanding"
  add_index "payments", ["payment_card_used_id"], :name => "index_payments_on_payment_card_used_id"
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
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

end
