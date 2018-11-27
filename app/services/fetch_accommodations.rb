require 'thread'
require 'thread/pool'
require 'open-uri'
require 'nokogiri'
require 'byebug'

# url = "https://www.booking.com/searchresults.en-gb.html?label=gen173nr-1DCAEoggI46AdIM1gEaHWIAQGYAQm4AQfIAQzYAQPoAQGIAgGoAgM&lang=en-gb&sid=de09dff5fbf4dd458853cf6d1bbb24e3&sb=1&src=index&src_elem=sb&error_url=https%3A%2F%2Fwww.booking.com%2Findex.en-gb.html%3Flabel%3Dgen173nr-1DCAEoggI46AdIM1gEaHWIAQGYAQm4AQfIAQzYAQPoAQGIAgGoAgM%3Bsid%3Dde09dff5fbf4dd458853cf6d1bbb24e3%3Bsb_price_type%3Dtotal%26%3B&ss=#{@city_name}&is_ski_area=0&ssne=Tokyo&ssne_untouched=Tokyo&selected_currency=USD&dest_id=-1456928&dest_type=city&checkin_monthday=#{@checkin_monthday}&checkin_month=#{@checkin_month}&checkin_year=#{@checkin_year}&checkout_monthday=#{@checkout_monthday}&checkout_month=#{@checkout_month}&checkout_year=#{@checkout_year}&no_rooms=1&group_adults=2&group_children=0&b_h4u_keep_filters=&from_sf=1"
class FetchAccommodations
  def self.call(region, outboundDate, inboundDate)
    puts "========== FETCH DATA ACCOM. BEGIN ========= >>> AT > #{Time.now}"
    fetch_begin = Time.now
    destinationplaces = []
    results = []
    htmls = []

    region.cities.each do |city|
      destinationplaces << city.name
    end

    currency = "USD"
    adult = "1"
    checkin_month = outboundDate[5..6]
    checkin_monthday = outboundDate[8..9]
    checkin_year = outboundDate[0..3]
    checkout_month = inboundDate[5..6]
    checkout_monthday = inboundDate[8..9]
    checkout_year = inboundDate[0..3]

    pool = Thread.pool(5)
    destinationplaces.each do |city_name|
      pool.process {
        url = "https://www.booking.com/searchresults.en-gb.html?"\
        "label=gen173nr-1DCAEoggI46AdIM1gEaHWIAQGYAQm4AQfIAQzYAQPoAQGIAgGoAgM&"\
        "lang=en-gb&sid=de09dff5fbf4dd458853cf6d1bbb24e3&"\
        "src_elem=sb&ss=#{city_name}&"\
        "is_ski_area=0&"\
        "selected_currency=#{currency}&"\
        "dest_type=city&"\
        "checkin_monthday=#{checkin_monthday}&"\
        "checkin_month=#{checkin_month}&"\
        "checkin_year=#{checkin_year}&"\
        "checkout_monthday=#{checkout_monthday}&"\
        "checkout_month=#{checkout_month}&"\
        "checkout_year=#{checkout_year}&"\
        "no_rooms=1&"\
        "group_adults=#{adult}&"\
        "order=price&"\
        "group_children=0&"

        html = open(url, {
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"
        }).read
        p "============ ACCOM. = POOLinner >> #{Time.now - fetch_begin}"
        htmls << html
      }
    end
    pool.shutdown

    htmls.each do |html|
      parsed_content = Nokogiri::HTML html
      contents = parsed_content.css(".sr_item")
      hotels_array = []

      contents.each do |content|
        name = content.css(".sr-hotel__title").css(".sr-hotel__name").text.strip rescue nil
        image_url = content.css(".hotel_image").attr('src').value rescue nil
        booking_url = content.css(".hotel_name_link").attr('href').value.strip rescue nil
        score = content.css(".bui-review-score__badge").inner_text.strip rescue nil
        price = content.css(".roomPrice").css(".price").inner_text.strip rescue nil
        address = content.css(".jq_tooltip").inner_text.strip.split("\n").first rescue nil

        hotel = {
          name: name,
          image_url: image_url,
          booking_url: "https://booking.com#{booking_url}",
          score: score,
          price: price,
          address: address 
        }
        hotels_array << hotel
      end
      results << hotels_array
    end

    puts "========== FETCH DATA ACCOM. END ========= >>> in > #{Time.now - fetch_begin} sec"
    return results
  end

  private

  def self.data_valid?(content)
    a = content.css(".sr-hotel__title").css(".sr-hotel__name").text.strip.present?
    b = content.css(".hotel_image").attr('src').value.present?
    c = content.css(".hotel_name_link").attr('href').value.strip.present?
    d = content.css(".bui-review-score__badge").inner_text.strip.present?
    e = content.css(".roomPrice").css(".price").inner_text.strip.present?
    f = content.css(".jq_tooltip").inner_text.strip.split("\n").first.present?
    return a && b && c && d && e && f
  end
end
