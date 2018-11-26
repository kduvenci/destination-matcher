require 'open-uri'
require 'nokogiri'
require 'byebug'

class FetchAccommodations
  def self.call(*args)
    new(*args).call
  end

  def initialize(city_name, checkin_month, checkin_monthday, checkin_year, checkout_month, checkout_monthday, checkout_year)
    @city_name = city_name
    @checkin_month = checkin_month
    @checkin_monthday = checkin_monthday
    @checkin_year = checkin_year
    @checkout_month = checkout_month
    @checkout_monthday = checkout_monthday
    @checkout_year = checkout_year
  end

  def call
    url = "https://www.booking.com/searchresults.en-gb.html?label=gen173nr-1FCAEoggI46AdIM1gEaHWIAQGYATG4AQfIAQzYAQHoAQH4AQKIAgGoAgM&lang=en-gb&sid=de09dff5fbf4dd458853cf6d1bbb24e3&sb=1&src=index&src_elem=sb&error_url=https%3A%2F%2Fwww.booking.com%2Findex.en-gb.html%3Flabel%3Dgen173nr-1FCAEoggI46AdIM1gEaHWIAQGYATG4AQfIAQzYAQHoAQH4AQKIAgGoAgM%3Bsid%3Dde09dff5fbf4dd458853cf6d1bbb24e3%3Bsb_price_type%3Dtotal%26%3B&ss=#{@city_name}&is_ski_area=0&ssne=Tokyo&ssne_untouched=Tokyo&dest_id=-246227&dest_type=city&checkin_monthday=#{@checkin_monthday}&checkin_month=#{@checkin_month}&checkin_year=#{@checkin_year}&checkout_monthday=#{@checkout_monthday}&checkout_month=#{@checkout_month}&checkout_year=#{@checkout_year}&no_rooms=1&group_adults=2&group_children=0&b_h4u_keep_filters=&from_sf=1"

    html = open(url, {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"
    }).read
    File.write("temp.html", html)
    parsed_content = Nokogiri::HTML html
    contents = parsed_content.css(".sr_item")
    hotels_array = Array.new

    contents.each do |content|
      hotel = {
        name: content.css(".sr-hotel__title").css(".sr-hotel__name").text.strip,
        image_url: content.css(".hotel_image").attr('src').value,
        booking_url: "https://booking.com" + content.css(".hotel_name_link").attr('href').value.strip,
        score: content.css(".bui-review-score__badge").inner_text.strip,
        # stars: content.css(".bk-icon-wrapper").inner_text.strip,
        price: content.css(".roomPrice").css(".price").inner_text.strip,
        address: content.css(".jq_tooltip").inner_text.strip.split("\n").first
      }
      hotels_array << hotel
    end

    results = hotels_array
    # result = results.first
    # puts result[:name]
    # puts result[:image_url]
    # puts result[:reviews]
    # puts result[:stars]
    # puts result[:price]
    # puts result[:address]
  end
  return results
end

FetchAccommodations.call("Seoul", 12, 13 ,2018, 12, 15, 2018)
