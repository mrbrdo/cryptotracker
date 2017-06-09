class Market
  class << self
    def currencies
      @currencies ||= Bittrex::Currency.all
    end

    def currency_name(abbreviation)
      currencies.find { |c| c.abbreviation.upcase == abbreviation.upcase }.try!(:name)
    end

    def disabled_markets
      return [] unless ENV['DISABLE_MARKETS'].present?

      ENV['DISABLE_MARKETS'].split(',')
    end

    def ticker
      return @last_ticker_data if @last_ticker_refresh && @last_ticker_refresh > 10.seconds.ago
      @last_ticker_refresh = DateTime.now
      @last_ticker_data = get_ticker
    end

    def get_ticker
      tickers = {}
      JSON.load(Poloniex.ticker).each_pair do |trade_pair, data|
        ticker = Ticker.new
        ticker.source = 'poloniex'
        ticker.pair = trade_pair.upcase
        ticker.last = data['last'].to_d
        tickers[ticker.pair] = ticker
      end

      Bittrex::Summary.all.each do |summary|
        trade_pair = summary.name.gsub('-', '_').upcase
        next if tickers[trade_pair]
        ticker = Ticker.new
        ticker.source = 'bittrex'
        ticker.pair = trade_pair
        ticker.last = summary.last
        tickers[ticker.pair] = ticker
      end

      tickers
    end
  end

  class Ticker
    attr_accessor :source
    attr_accessor :pair
    attr_accessor :last
  end
end
