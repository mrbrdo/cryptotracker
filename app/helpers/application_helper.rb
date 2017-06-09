module ApplicationHelper
  def btc(value, decimals = 8)
    value ||= 0.0
    "%.#{decimals}f" % value
  end

  def profit_color(value)
    red_green(btc(value), value.to_f > 0)
  end

  def ratio_percent(value)
    "%+d" % (value * 100).round + "%"
  end

  def crypto_currency(data)
    name = Market.currency_name(data[:trade_currency])
    icon =
      if name
        %{<img src="https://files.coinmarketcap.com/static/img/coins/16x16/#{name.downcase}.png" onerror="this.parentNode.removeChild(this)">&nbsp;}
      end
    %{<a href="#{data[:exchange_link]}" target="_blank">#{icon}#{html_escape data[:trade_currency]}</a>}.html_safe
  end

  def red_green(value, green, icon: false)
    icon_html =
      if icon
        if green
          %{<i class="fa fa-caret-up" aria-hidden="true"></i>&nbsp;}
        else
          %{<i class="fa fa-caret-down" aria-hidden="true"></i>&nbsp;}
        end
      else
        ""
      end
    if green
      %{<span style="color: green">#{icon_html}#{html_escape value}</span>}.html_safe
    else
      %{<span style="color: red">#{icon_html}#{html_escape value}</span>}.html_safe
    end
  end
end
