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

ActiveRecord::Schema[7.2].define(version: 2026_03_03_003402) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "listings", force: :cascade do |t|
    t.integer "listing_number", null: false
    t.decimal "listing_price", precision: 15, scale: 2
    t.string "listing_status", null: false
    t.text "summary"
    t.string "hubspot_deal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hubspot_deal_id"], name: "index_listings_on_hubspot_deal_id"
    t.index ["listing_number"], name: "index_listings_on_listing_number", unique: true
    t.index ["listing_status"], name: "index_listings_on_listing_status"
  end
end
