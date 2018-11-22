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

ActiveRecord::Schema.define(version: 2018_11_22_084022) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accommodations", force: :cascade do |t|
    t.bigint "city_id"
    t.string "name"
    t.integer "price"
    t.integer "star"
    t.string "photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_accommodations_on_city_id"
  end

  create_table "cities", force: :cascade do |t|
    t.bigint "country_id"
    t.string "name"
    t.string "photo"
    t.integer "meal_average_price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "airport_key"
    t.index ["country_id"], name: "index_cities_on_country_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "language"
    t.integer "english_level"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.index ["region_id"], name: "index_countries_on_region_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "accommodation_id"
    t.bigint "flight_id"
    t.integer "budget"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["accommodation_id"], name: "index_favorites_on_accommodation_id"
    t.index ["flight_id"], name: "index_favorites_on_flight_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "flights", force: :cascade do |t|
    t.string "departure_location"
    t.string "return_location"
    t.integer "price"
    t.string "airline_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "city_id"
    t.datetime "depart_arrival_time"
    t.datetime "depart_departure_time"
    t.datetime "return_arrival_time"
    t.datetime "return_departure_time"
    t.index ["city_id"], name: "index_flights_on_city_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "nationality"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accommodations", "cities"
  add_foreign_key "cities", "countries"
  add_foreign_key "countries", "regions"
  add_foreign_key "favorites", "accommodations"
  add_foreign_key "favorites", "flights"
  add_foreign_key "favorites", "users"
  add_foreign_key "flights", "cities"
end
