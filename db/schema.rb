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

ActiveRecord::Schema[7.2].define(version: 2025_12_26_051145) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "choices", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.string "text", null: false
    t.boolean "is_correct", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_choices_on_quiz_id"
  end

  create_table "course_quizzes", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_quizzes_on_course_id"
    t.index ["quiz_id"], name: "index_course_quizzes_on_quiz_id"
  end

  create_table "course_results", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.integer "correct_count", default: 0, null: false
    t.integer "total_questions", default: 0, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_results_on_course_id"
    t.index ["user_id"], name: "index_course_results_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "name", null: false
    t.integer "max_questions", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_courses_on_category_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "token_digest", null: false
    t.datetime "send_token_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_invitations_on_room_id"
  end

  create_table "quiz_categories", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_quiz_categories_on_category_id"
    t.index ["quiz_id"], name: "index_quiz_categories_on_quiz_id"
  end

  create_table "quiz_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_result_id", null: false
    t.bigint "quiz_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_result_id"], name: "index_quiz_histories_on_course_result_id"
    t.index ["quiz_id"], name: "index_quiz_histories_on_quiz_id"
    t.index ["user_id"], name: "index_quiz_histories_on_user_id"
  end

  create_table "quiz_history_choices", force: :cascade do |t|
    t.bigint "quiz_history_id", null: false
    t.bigint "choice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_id"], name: "index_quiz_history_choices_on_choice_id"
    t.index ["quiz_history_id"], name: "index_quiz_history_choices_on_quiz_history_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "name", null: false
    t.text "sentence", null: false
    t.text "explanation"
    t.integer "give_point"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "total_point", default: 0
    t.integer "role", default: 0, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "room_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["room_id"], name: "index_users_on_room_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "choices", "quizzes"
  add_foreign_key "course_quizzes", "courses"
  add_foreign_key "course_quizzes", "quizzes"
  add_foreign_key "course_results", "courses"
  add_foreign_key "course_results", "users"
  add_foreign_key "courses", "categories"
  add_foreign_key "invitations", "rooms"
  add_foreign_key "quiz_categories", "categories"
  add_foreign_key "quiz_categories", "quizzes"
  add_foreign_key "quiz_histories", "course_results"
  add_foreign_key "quiz_histories", "quizzes"
  add_foreign_key "quiz_histories", "users"
  add_foreign_key "quiz_history_choices", "choices"
  add_foreign_key "quiz_history_choices", "quiz_histories"
  add_foreign_key "users", "rooms"
end
