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

ActiveRecord::Schema[7.1].define(version: 2024_07_13_211704) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "service_days", force: :cascade do |t|
    t.integer "day"
    t.bigint "service_week_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_week_id"], name: "index_service_days_on_service_week_id"
  end

  create_table "service_hours", force: :cascade do |t|
    t.integer "hour"
    t.bigint "service_day_id", null: false
    t.bigint "designated_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["designated_user_id"], name: "index_service_hours_on_designated_user_id"
    t.index ["service_day_id"], name: "index_service_hours_on_service_day_id"
  end

  create_table "service_hours_users", force: :cascade do |t|
    t.bigint "service_hour_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_hour_id"], name: "index_service_hours_users_on_service_hour_id"
    t.index ["user_id"], name: "index_service_hours_users_on_user_id"
  end

  create_table "service_weeks", force: :cascade do |t|
    t.integer "week"
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_service_weeks_on_service_id"
  end

  create_table "service_working_days", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.integer "day"
    t.integer "from"
    t.integer "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_service_working_days_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti"
    t.string "name"
    t.integer "role", default: 0
    t.integer "color"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "service_days", "service_weeks"
  add_foreign_key "service_hours", "service_days"
  add_foreign_key "service_hours", "users", column: "designated_user_id"
  add_foreign_key "service_hours_users", "service_hours"
  add_foreign_key "service_hours_users", "users"
  add_foreign_key "service_weeks", "services"
  add_foreign_key "service_working_days", "services"
end
