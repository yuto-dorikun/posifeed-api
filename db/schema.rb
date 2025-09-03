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

ActiveRecord::Schema[7.2].define(version: 2025_09_03_133437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departments", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "parent_id"
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_departments_on_active"
    t.index ["organization_id", "name"], name: "index_departments_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_departments_on_organization_id"
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "feedback_reactions", force: :cascade do |t|
    t.bigint "feedback_id", null: false
    t.bigint "user_id", null: false
    t.integer "reaction_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_id", "user_id"], name: "index_feedback_reactions_on_feedback_id_and_user_id", unique: true
    t.index ["feedback_id"], name: "index_feedback_reactions_on_feedback_id"
    t.index ["reaction_type"], name: "index_feedback_reactions_on_reaction_type"
    t.index ["user_id"], name: "index_feedback_reactions_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.bigint "organization_id", null: false
    t.integer "category", null: false
    t.text "message", null: false
    t.boolean "is_anonymous", default: false, null: false
    t.datetime "read_at"
    t.integer "reactions_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "created_at"], name: "index_feedbacks_on_organization_id_and_created_at", order: { created_at: :desc }
    t.index ["organization_id"], name: "index_feedbacks_on_organization_id"
    t.index ["receiver_id", "created_at"], name: "index_feedbacks_on_receiver_id_and_created_at", order: { created_at: :desc }
    t.index ["receiver_id", "read_at"], name: "index_feedbacks_on_receiver_id_and_read_at", where: "(read_at IS NULL)"
    t.index ["receiver_id"], name: "index_feedbacks_on_receiver_id"
    t.index ["sender_id", "created_at"], name: "index_feedbacks_on_sender_id_and_created_at", order: { created_at: :desc }
    t.index ["sender_id"], name: "index_feedbacks_on_sender_id"
    t.check_constraint "category = ANY (ARRAY[0, 1, 2, 3])", name: "valid_category"
    t.check_constraint "char_length(message) > 0 AND char_length(message) <= 1000", name: "message_length"
    t.check_constraint "sender_id <> receiver_id", name: "no_self_feedback"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exp"], name: "index_jwt_denylists_on_exp"
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
    t.index ["user_id"], name: "index_jwt_denylists_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "domain"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_organizations_on_active"
    t.index ["domain"], name: "index_organizations_on_domain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "department_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "display_name"
    t.string "job_title"
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.integer "sent_feedbacks_count", default: 0, null: false
    t.integer "received_feedbacks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["organization_id", "active"], name: "index_users_on_organization_id_and_active"
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "departments", "organizations"
  add_foreign_key "feedback_reactions", "feedbacks"
  add_foreign_key "feedback_reactions", "users"
  add_foreign_key "feedbacks", "organizations"
  add_foreign_key "feedbacks", "users", column: "receiver_id"
  add_foreign_key "feedbacks", "users", column: "sender_id"
  add_foreign_key "jwt_denylists", "users"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "organizations"
end
