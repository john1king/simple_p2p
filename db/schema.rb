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

ActiveRecord::Schema.define(version: 20170519134635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "loans", force: :cascade do |t|
    t.integer "lender_id"
    t.integer "borrower_id"
    t.decimal "money", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrower_id"], name: "index_loans_on_borrower_id"
    t.index ["lender_id", "borrower_id"], name: "index_loans_on_lender_id_and_borrower_id", unique: true
  end

  create_table "tradings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "target_user_id", null: false
    t.string "type", null: false
    t.decimal "money", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_user_id"], name: "index_tradings_on_target_user_id"
    t.index ["user_id"], name: "index_tradings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
