class DashboardController < ApplicationController
  def show
    MarketTrade.refresh
    @market_data =
      get_market_data.sort_by { |d| -d[:holdings_btc] }
      .select { |d| !d[:trade_pair].in?(Market.disabled_markets) }
  end

private
  def get_market_data
    MarketTrade.pluck("DISTINCT trade_pair")
    .select { |trade_pair| Market.ticker[trade_pair].present? }
    .map do |trade_pair|
      rate = Market.ticker[trade_pair].last

      bought_base =
        MarketTrade.where(trade_pair: trade_pair)
        .where(trade_type: 'buy').pluck("SUM(to_amount), SUM(from_amount)").first
      sold_base =
        MarketTrade.where(trade_pair: trade_pair)
        .where(trade_type: 'sell').pluck("SUM(from_amount), SUM(to_amount), MAX(trade_at)").first

      last_trade = MarketTrade.where(trade_pair: trade_pair).order(:trade_at).last

      open_buy_trades =
        MarketTrade.where(trade_pair: trade_pair)
        .where(trade_type: 'buy').where(buy_settled: false).order(:trade_at)

      open_buy_trade_costs =
        open_buy_trades.each_with_object([]) do |e, a|
          a.push([e.to_amount, e.rate, e.all_time_bought])
        end

      settled_buys =
        MarketTrade.where(trade_pair: trade_pair)
        .where(trade_type: 'buy').where(buy_settled: true)
        .pluck("COALESCE(SUM(to_amount), 0), COALESCE(SUM(from_amount), 0)").first

      unless open_buy_trade_costs.empty?
        prev_amount = open_buy_trade_costs[0][0]
        open_buy_trade_costs[0][0] = open_buy_trade_costs[0][2] - last_trade.all_time_sold
        already_sold_amount = prev_amount - open_buy_trade_costs[0][0]
        if already_sold_amount > 0
          settled_buys[0] += already_sold_amount
          settled_buys[1] += already_sold_amount * open_buy_trade_costs[0][1]
        end
      end

      holdings = (bought_base[0] || 0) - (sold_base[0] || 0)
      holdings_btc = holdings * rate

      if holdings_btc < 0.009
        holdings = 0
        holdings_btc = 0
      end

      break_even_amount =
        open_buy_trade_costs.reduce(0) do |a, e|
          a + e[0] * e[1]
        end
      break_even_rate = safe_div(break_even_amount, holdings)
      holdings_buy_cost = holdings * break_even_rate
      holdings_profit = holdings_btc - holdings_buy_cost
      sales_profit = BigDecimal(sold_base[1] || 0) - BigDecimal(settled_buys[1] || 0)
      exchange_link =
        case Market.ticker[trade_pair].source
        when 'poloniex'
          "https://poloniex.com/exchange##{trade_pair.downcase}"
        else
          "https://bittrex.com/Market/Index?MarketName=#{trade_pair.gsub('_', '-').upcase}"
        end

      {
        trade_pair: trade_pair,
        base_currency: trade_pair.split("_")[0],
        trade_currency: trade_pair.split("_")[1],
        average_buy_price: safe_div(bought_base[1], bought_base[0]),
        average_sell_price: safe_div(sold_base[1], sold_base[0]),
        sold_amount: settled_buys[0],
        sold_price: safe_div(sold_base[1], sold_base[0]),
        last_sold_at: sold_base[2],
        sales_profit: sales_profit,
        sales_buy_cost: BigDecimal(settled_buys[1] || 0),
        sales_profit_ratio: safe_div(sales_profit, settled_buys[1]),
        holdings: holdings,
        holdings_btc: holdings_btc,
        rate: rate,
        break_even_rate: break_even_rate,
        holdings_profit: holdings_profit,
        holdings_buy_cost: holdings_buy_cost,
        holdings_profit_ratio: safe_div(holdings_profit, holdings_btc),
        exchange_link: exchange_link
      }
    end
  end

  def safe_div(numerator, denominator)
    return 0 if denominator.nil? || denominator.zero?
    numerator / denominator
  end
end
