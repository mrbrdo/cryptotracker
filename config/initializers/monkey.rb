# for displaying BTC prices better
class BigDecimal
  def inspect
    "%.8f" % self
  end
end
