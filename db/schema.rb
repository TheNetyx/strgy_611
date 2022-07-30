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

ActiveRecord::Schema[7.0].define(version: 2022_05_01_122902) do
  create_table "item_logs", force: :cascade do |t|
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_requests", force: :cascade do |t|
    t.integer "team"
    t.integer "item"
    t.string "targetcell"
    t.integer "targetplayer"
    t.boolean "processed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer "identifier"
    t.string "name"
    t.integer "t1"
    t.integer "t2"
    t.integer "t3"
    t.integer "t4"
    t.integer "t5"
    t.integer "t6"
    t.integer "t7"
    t.integer "t8"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fields"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "xpos"
    t.integer "ypos"
    t.integer "team"
    t.boolean "alive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "respawn_round"
  end

  create_table "rounds", force: :cascade do |t|
    t.integer "round"
    t.boolean "t1"
    t.boolean "t2"
    t.boolean "t3"
    t.boolean "t4"
    t.boolean "t5"
    t.boolean "t6"
    t.boolean "t7"
    t.boolean "t8"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "t1s"
    t.integer "t2s"
    t.integer "t3s"
    t.integer "t4s"
    t.integer "t5s"
    t.integer "t6s"
    t.integer "t7s"
    t.integer "t8s"
    t.integer "state"
  end

end
