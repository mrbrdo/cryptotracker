class CreateMarketTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :market_trades do |t|
      t.string :external_id, null: false
      t.string :source, null: false
      t.decimal :all_time_bought, scale: 8, precision: 18, null: false
      t.decimal :all_time_sold, scale: 8, precision: 18, null: false
      t.boolean :buy_settled, null: false, default: false

      t.datetime :trade_at, null: false
      t.decimal :rate, scale: 8, precision: 14, null: false
      t.decimal :amount, scale: 8, precision: 18, null: false
      t.string :trade_type, null: false
      t.string :trade_pair, null: false

      t.decimal :fee_rate, scale: 6, precision: 7, null: false
      t.decimal :fee, scale: 8, precision: 14, null: false

      t.decimal :base_fee, scale: 8, precision: 18, null: false
      t.decimal :base_total, scale: 8, precision: 18, null: false

      t.string :from_currency, null: false
      t.string :to_currency, null: false
      t.decimal :from_amount, scale: 8, precision: 18, null: false
      t.decimal :to_amount, scale: 8, precision: 18, null: false

      t.timestamps
    end

    add_index :market_trades, [:source, :external_id], unique: true
    add_index :market_trades, :source
    add_index :market_trades, :trade_at
    add_index :market_trades, :from_currency
    add_index :market_trades, :to_currency
    add_index :market_trades, :trade_pair
    add_index :market_trades, :trade_type
  end
end
