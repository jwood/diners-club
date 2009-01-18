# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "declined_outings", :id => false, :force => true do |t|
    t.integer "outing_id"
    t.integer "diner_id"
  end

  add_index "declined_outings", ["diner_id"], :name => "fk_declined_diner"
  add_index "declined_outings", ["outing_id"], :name => "fk_declined_outing"

  create_table "diners", :force => true do |t|
    t.string  "first_name",                                    :null => false
    t.string  "last_name",                                     :null => false
    t.string  "email"
    t.string  "address_line_1"
    t.string  "address_line_2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.text    "food_preferences"
    t.boolean "send_email_on_outing_change", :default => true
  end

  create_table "diners_outings", :id => false, :force => true do |t|
    t.integer "outing_id"
    t.integer "diner_id"
  end

  add_index "diners_outings", ["diner_id"], :name => "fk_diner"
  add_index "diners_outings", ["outing_id"], :name => "fk_outing"

  create_table "outings", :force => true do |t|
    t.datetime "reservation_time"
    t.string   "restaurant_name"
    t.string   "restaurant_address_line_1"
    t.string   "restaurant_address_line_2"
    t.string   "restaurant_city"
    t.string   "restaurant_state"
    t.string   "restaurant_zip"
    t.string   "restaurant_phone"
    t.text     "restaurant_description"
    t.string   "restaurant_website"
    t.integer  "diner_id"
    t.string   "afterparty_bar_name"
    t.string   "afterparty_address_line_1"
    t.string   "afterparty_address_line_2"
    t.string   "afterparty_city"
    t.string   "afterparty_state"
    t.string   "afterparty_zip"
    t.integer  "afterparty_sponsor_id"
  end

  add_index "outings", ["afterparty_sponsor_id"], :name => "fk_afterparty_sponsor_id"
  add_index "outings", ["diner_id"], :name => "fk_sponsor"

end
