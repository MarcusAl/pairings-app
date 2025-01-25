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

ActiveRecord::Schema[8.0].define(version: 2025_01_25_132917) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "category", null: false
    t.string "subcategory"
    t.string "image_key"
    t.uuid "user_id", null: false
    t.boolean "public", default: false
    t.string "flavor_profiles", default: [], array: true
    t.string "primary_flavor_profile"
    t.string "price_range"
    t.json "attributes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flavor_profiles"], name: "index_items_on_flavor_profiles", using: :gin
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "pairings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "item1_id", null: false
    t.uuid "item2_id", null: false
    t.uuid "user_id", null: false
    t.integer "strength"
    t.text "pairing_notes"
    t.text "ai_reasoning"
    t.float "confidence_score"
    t.boolean "public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item1_id", "item2_id", "user_id"], name: "index_pairings_on_item1_id_and_item2_id_and_user_id", unique: true
    t.index ["item1_id"], name: "index_pairings_on_item1_id"
    t.index ["item2_id"], name: "index_pairings_on_item2_id"
    t.index ["user_id"], name: "index_pairings_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "items", "users"
  add_foreign_key "pairings", "items", column: "item1_id"
  add_foreign_key "pairings", "items", column: "item2_id"
  add_foreign_key "pairings", "users"
  add_foreign_key "sessions", "users"
end
