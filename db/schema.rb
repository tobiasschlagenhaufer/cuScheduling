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

ActiveRecord::Schema.define(version: 20191108005801) do

  create_table "lectures", force: :cascade do |t|
    t.string "name"
    t.string "section"
    t.string "term"
    t.string "days"
    t.string "s_time"
    t.string "e_time"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "also_reg"
    t.string "status"
  end

  create_table "tutorials", force: :cascade do |t|
    t.integer "course_id"
    t.string "name"
    t.string "section"
    t.string "term"
    t.string "days"
    t.string "s_time"
    t.string "e_time"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

end
