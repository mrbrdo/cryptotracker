require 'poloniex'
require 'bittrex'

Poloniex.setup do | config |
    config.key = ENV['POLONIEX_API_KEY']
    config.secret = ENV['POLONIEX_API_SECRET']
end

Bittrex.config do |c|
  c.key = ENV['BITTREX_API_KEY']
  c.secret = ENV['BITTREX_API_SECRET']
end
