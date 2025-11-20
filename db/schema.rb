# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_20_100000) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount"
    t.date "date"
    t.text "description"
    t.integer "category_id", null: false
    t.integer "receipt_id", null: false
    t.integer "vendor_id", null: false
    t.integer "status"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["receipt_id"], name: "index_expenses_on_receipt_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
    t.index ["vendor_id"], name: "index_expenses_on_vendor_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.string "merchant"
    t.decimal "amount"
    t.date "date"
    t.string "image"
    t.text "notes"
    t.integer "vendor_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_receipts_on_user_id"
    t.index ["vendor_id"], name: "index_receipts_on_vendor_id"
  end

  create_table "rules", force: :cascade do |t|
    t.string "pattern"
    t.integer "category_id", null: false
    t.decimal "amount_threshold"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_rules_on_category_id"
    t.index ["user_id"], name: "index_rules_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "phone"
    t.string "email"
    t.string "tax_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "categories", "users"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "receipts"
  add_foreign_key "expenses", "users"
  add_foreign_key "expenses", "vendors"
  add_foreign_key "receipts", "users"
  add_foreign_key "receipts", "vendors"
  add_foreign_key "rules", "categories"
  add_foreign_key "rules", "users"
end
