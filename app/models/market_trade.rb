class MarketTrade < ApplicationRecord
  validates :trade_type, inclusion: { in: ['buy', 'sell'] }
  scope :chronological, -> { order("trade_at, id") }

  def infer_data!
    trade_currencies = trade_pair.split('_')

    self.base_total = self.amount * self.rate

    if self.trade_type == 'buy'
      self.from_currency = trade_currencies[0]
      self.to_currency = trade_currencies[1]
      self.from_amount = self.amount * self.rate
      self.to_amount = self.amount
    else
      self.from_currency = trade_currencies[1]
      self.to_currency = trade_currencies[0]
      self.from_amount = self.amount
      self.to_amount = self.amount * self.rate
    end

    self.all_time_bought = 0
    self.all_time_sold = 0
  end

  def refresh_current_balance!
    fail unless id
    data =
      MarketTrade.where(trade_pair: trade_pair)
      .where("trade_at < ? OR (trade_at = ? AND id < ?)", trade_at, trade_at, id)
      .pluck("SUM(CASE WHEN trade_type = 'buy' THEN to_amount ELSE 0 END), SUM(CASE WHEN trade_type = 'sell' THEN from_amount ELSE 0 END)")
      .first || []
    self.all_time_bought = data[0] || BigDecimal(0)
    self.all_time_sold = data[1] || BigDecimal(0)
    if trade_type == 'buy'
      self.all_time_bought += to_amount
    else
      self.all_time_sold += from_amount
      MarketTrade.where(trade_pair: trade_pair)
      .where(trade_type: 'buy').where("all_time_bought <= ?", all_time_sold)
      .update_all(buy_settled: true)
    end
  end

  def self.refresh_current_balances
    MarketTrade.all.update_all(buy_settled: false)
    order(:trade_at).each do |record|
      record.refresh_current_balance!
      record.save!
    end
  end

  def self.refresh
    return if @last_refresh_at && @last_refresh_at >= 1.minute.ago
    @last_refresh_at = DateTime.now
    import_all
  end

  def self.import_all
    start_date = MarketTrade.order(:trade_at).last.try!(:trade_at)
    start_date ||= 1.year.ago
    start_date -= 1.day
    import_poloniex(start_date)
    import_bittrex(start_date)
    refresh_current_balances
  end

  def self.import_poloniex(start_date)
    data = JSON.load(Poloniex.trade_history('all'))
    data.each_pair do |trade_pair, trades|
      trades.reverse_each do |trade|
        trade_date = DateTime.parse(trade['date'])
        next if trade_date < start_date
        trade_id = trade['globalTradeID'].to_s
        next if exists?(source: 'poloniex', external_id: trade_id)
        record =
          new(
            external_id: trade_id,
            source: 'poloniex',
            trade_at: trade_date,
            rate: trade['rate'].to_d,
            amount: trade['amount'].to_d,
            fee_rate: trade['fee'].to_d,
            trade_type: trade['type'].downcase,
            trade_pair: trade_pair.upcase
          )

        record.infer_data!
        record.base_fee = record.base_total * record.fee_rate
        record.fee = record.to_amount * record.fee_rate
        record.to_amount -= record.fee
        record.save!
      end
    end
  end

  def self.import_bittrex(start_date)
    data = Bittrex::Order.history
    data.reverse_each do |trade|
      trade_date = DateTime.parse(trade.raw["TimeStamp"])
      next if trade_date < start_date
      trade_id = trade.id.to_s
      next if exists?(source: 'bittrex', external_id: trade_id)
      record =
        new(
          external_id: trade_id,
          source: 'bittrex',
          trade_at: trade_date,
          rate: trade.raw["PricePerUnit"],
          amount: trade.quantity - trade.remaining,
          trade_type: trade.type.downcase.gsub("limit_", ""),
          trade_pair: trade.exchange.gsub('-', '_').upcase
        )

      record.infer_data!
      record.base_fee = trade.raw['Commission']
      record.fee_rate = record.base_fee / trade.raw['Price']
      if record.trade_type == 'buy'
        record.fee = 0
        record.from_amount += record.fee
      else
        record.fee = trade.raw['Commission']
        record.to_amount -= record.fee
      end
      record.save!
    end
  end
end
