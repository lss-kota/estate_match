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

ActiveRecord::Schema[8.0].define(version: 2025_08_16_071917) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conversations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "buyer_id"
    t.bigint "owner_id", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "agent_id"
    t.bigint "inquiry_id"
    t.integer "conversation_type", default: 0, null: false
    t.index ["agent_id", "owner_id"], name: "index_conversations_on_agent_owner"
    t.index ["agent_id"], name: "index_conversations_on_agent_id"
    t.index ["buyer_id"], name: "index_conversations_on_buyer_id"
    t.index ["conversation_type", "property_id"], name: "index_conversations_on_conversation_type_and_property_id"
    t.index ["inquiry_id"], name: "index_conversations_on_inquiry_id"
    t.index ["owner_id"], name: "index_conversations_on_owner_id"
    t.index ["property_id", "buyer_id", "owner_id"], name: "index_conversations_on_property_id_and_buyer_id_and_owner_id", unique: true
    t.index ["property_id"], name: "index_conversations_on_property_id"
  end

  create_table "favorites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_favorites_on_property_id"
    t.index ["user_id", "property_id"], name: "index_favorites_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "inquiries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "agent_id", null: false
    t.integer "status", default: 0, null: false
    t.text "message"
    t.datetime "contacted_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_inquiries_on_agent_id"
    t.index ["buyer_id"], name: "index_inquiries_on_buyer_id"
    t.index ["created_at"], name: "index_inquiries_on_created_at"
    t.index ["property_id", "buyer_id"], name: "index_inquiries_on_property_id_and_buyer_id", unique: true
    t.index ["property_id"], name: "index_inquiries_on_property_id"
    t.index ["status"], name: "index_inquiries_on_status"
  end

  create_table "membership_plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "monthly_property_limit", default: 0, null: false
    t.integer "monthly_price", default: 0, null: false
    t.text "features"
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_membership_plans_on_active"
    t.index ["sort_order"], name: "index_membership_plans_on_sort_order"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "content", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id", "created_at"], name: "index_messages_on_sender_id_and_created_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "partnerships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "owner_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.decimal "commission_rate", precision: 5, scale: 2
    t.text "terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "agent_requested_at"
    t.datetime "owner_requested_at"
    t.index ["agent_id", "owner_id"], name: "index_partnerships_on_agent_id_and_owner_id", unique: true
    t.index ["agent_id"], name: "index_partnerships_on_agent_id"
    t.index ["owner_id"], name: "index_partnerships_on_owner_id"
    t.index ["started_at"], name: "index_partnerships_on_started_at"
    t.index ["status"], name: "index_partnerships_on_status"
  end

  create_table "properties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "sale_price"
    t.integer "rental_price"
    t.integer "deposit"
    t.integer "key_money"
    t.integer "management_fee"
    t.string "prefecture"
    t.string "city"
    t.string "address"
    t.string "nearest_station"
    t.integer "station_distance"
    t.integer "property_type"
    t.decimal "building_area", precision: 10
    t.decimal "land_area", precision: 10
    t.string "rooms"
    t.integer "construction_year"
    t.boolean "parking"
    t.string "floor_plan_image"
    t.integer "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "property_tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_tags_on_property_id"
    t.index ["tag_id"], name: "index_property_tags_on_tag_id"
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.string "category"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "otp_secret_key"
    t.boolean "otp_required_for_login", default: false
    t.string "name"
    t.integer "user_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "membership_plan_id"
    t.string "company_name"
    t.string "license_number"
    t.integer "monthly_message_count", default: 0
    t.datetime "message_count_reset_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["license_number"], name: "index_users_on_license_number", unique: true
    t.index ["membership_plan_id"], name: "index_users_on_membership_plan_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "inquiries"
  add_foreign_key "conversations", "properties"
  add_foreign_key "conversations", "users", column: "agent_id"
  add_foreign_key "conversations", "users", column: "buyer_id"
  add_foreign_key "conversations", "users", column: "owner_id"
  add_foreign_key "favorites", "properties"
  add_foreign_key "favorites", "users"
  add_foreign_key "inquiries", "properties"
  add_foreign_key "inquiries", "users", column: "agent_id"
  add_foreign_key "inquiries", "users", column: "buyer_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "partnerships", "users", column: "agent_id"
  add_foreign_key "partnerships", "users", column: "owner_id"
  add_foreign_key "properties", "users"
  add_foreign_key "property_tags", "properties"
  add_foreign_key "property_tags", "tags"
  add_foreign_key "users", "membership_plans"
end
