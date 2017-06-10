require 'open-uri'
class ChartsController < ApplicationController
  def ticks
    case Market.ticker[params[:market]].source
    when 'poloniex'
      render plain: getPoloniexChartData
    else
      render plain: getBittrexChartData
    end
  end

private
  def getPoloniexChartData
    open("https://poloniex.com/public?command=returnChartData&currencyPair=#{params[:market]}&start=#{1.month.ago.to_i}&end=9999999999&period=1800").read
  end

  def getBittrexChartData
    open("https://bittrex.com/Api/v2.0/pub/market/GetTicks?marketName=#{params[:market].gsub("_", "-")}&tickInterval=thirtyMin").read
  end
end
