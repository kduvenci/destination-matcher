class FetchAccommodations
  # url = "https://www.booking.com/searchresults.en-gb.html?label=gen173nr-1DCAEoggI46AdIM1gEaHWIAQGYAQm4AQfIAQzYAQPoAQGIAgGoAgM&lang=en-gb&sid=de09dff5fbf4dd458853cf6d1bbb24e3&sb=1&src=index&src_elem=sb&error_url=https%3A%2F%2Fwww.booking.com%2Findex.en-gb.html%3Flabel%3Dgen173nr-1DCAEoggI46AdIM1gEaHWIAQGYAQm4AQfIAQzYAQPoAQGIAgGoAgM%3Bsid%3Dde09dff5fbf4dd458853cf6d1bbb24e3%3Bsb_price_type%3Dtotal%26%3B&ss=#{@city_name}&is_ski_area=0&ssne=Tokyo&ssne_untouched=Tokyo&selected_currency=USD&dest_id=-1456928&dest_type=city&checkin_monthday=#{@checkin_monthday}&checkin_month=#{@checkin_month}&checkin_year=#{@checkin_year}&checkout_monthday=#{@checkout_monthday}&checkout_month=#{@checkout_month}&checkout_year=#{@checkout_year}&no_rooms=1&group_adults=2&group_children=0&b_h4u_keep_filters=&from_sf=1"
  def self.call(region, outboundDate, inboundDate, pool, results)
    currency = "USD"
    adult = "1"
    checkin_month = outboundDate[5..6]
    checkin_monthday = outboundDate[8..9]
    checkin_year = outboundDate[0..3]
    checkout_month = inboundDate[5..6]
    checkout_monthday = inboundDate[8..9]
    checkout_year = inboundDate[0..3]

    region.cities.each do |city|
      pool.process {
        city_name = city.name

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
        "group_children=0"

        html = open(url, {
          :proxy_http_basic_authentication => ['http://zproxy.lum-superproxy.io:22225/', "lum-customer-hl_38c0c709-zone-zone1", "bnywmqts56jx"],
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
          :read_timeout => 7
        }).read

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

          hotels_array << {
            city: city_name,
            name: name,
            image_url: image_url,
            booking_url: "https://booking.com#{booking_url}",
            score: score,
            price: price,
            address: address 
          }
        end
        results << hotels_array
      }
    end
  end
end
