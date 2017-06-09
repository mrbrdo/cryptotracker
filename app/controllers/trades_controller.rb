class TradesController < ApplicationController
  def index
    @trades = MarketTrade.where(trade_pair: params[:currency_id]).order('trade_at desc')
  end
end
