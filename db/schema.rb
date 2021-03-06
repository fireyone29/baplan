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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170325010923) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "goals", force: :cascade do |t|
    t.integer  "user_id",                           null: false
    t.string   "description",                       null: false
    t.integer  "frequency",             default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.bigint   "longest_streak_length", default: 0, null: false
    t.index ["description", "user_id"], name: "index_goals_on_description_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_goals_on_user_id", using: :btree
  end

  create_table "streaks", force: :cascade do |t|
    t.string  "type"
    t.integer "goal_id",    null: false
    t.date    "start_date", null: false
    t.date    "end_date",   null: false
    t.index ["end_date"], name: "index_streaks_on_end_date", using: :btree
    t.index ["goal_id"], name: "index_streaks_on_goal_id", using: :btree
    t.index ["start_date"], name: "index_streaks_on_start_date", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "time_zone"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  add_foreign_key "goals", "users"
  add_foreign_key "streaks", "goals"
end
