# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121013025128) do

  create_table "tomes", :force => true do |t|
    t.integer  "owner_id",                             :null => false
    t.integer  "level",              :default => 1,    :null => false
    t.string   "profession"
    t.string   "name"
    t.integer  "intelligence"
    t.integer  "charisma"
    t.integer  "strength"
    t.integer  "wisdom"
    t.integer  "will"
    t.integer  "confidence"
    t.integer  "morality"
    t.integer  "ethics"
    t.boolean  "publicly_available", :default => true, :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
