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

ActiveRecord::Schema.define(version: 20170608143237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "market_trades", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "source", null: false
    t.decimal "all_time_bought", precision: 18, scale: 8, null: false
    t.decimal "all_time_sold", precision: 18, scale: 8, null: false
    t.boolean "buy_settled", default: false, null: false
    t.datetime "trade_at", null: false
    t.decimal "rate", precision: 14, scale: 8, null: false
    t.decimal "amount", precision: 18, scale: 8, null: false
    t.string "trade_type", null: false
    t.string "trade_pair", null: false
    t.decimal "fee_rate", precision: 7, scale: 6, null: false
    t.decimal "fee", precision: 14, scale: 8, null: false
    t.decimal "base_fee", precision: 18, scale: 8, null: false
    t.decimal "base_total", precision: 18, scale: 8, null: false
    t.string "from_currency", null: false
    t.string "to_currency", null: false
    t.decimal "from_amount", precision: 18, scale: 8, null: false
    t.decimal "to_amount", precision: 18, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_currency"], name: "index_market_trades_on_from_currency"
    t.index ["source", "external_id"], name: "index_market_trades_on_source_and_external_id", unique: true
    t.index ["source"], name: "index_market_trades_on_source"
    t.index ["to_currency"], name: "index_market_trades_on_to_currency"
    t.index ["trade_at"], name: "index_market_trades_on_trade_at"
    t.index ["trade_pair"], name: "index_market_trades_on_trade_pair"
    t.index ["trade_type"], name: "index_market_trades_on_trade_type"
  end

end
