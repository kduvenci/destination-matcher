# require 'thread'
# require 'thread/pool'
# require 'json'
# require 'rest-client'

class FetchFlights
  def self.call(origin, region, outboundDate, inboundDate)
    puts "========== FETCH DATA FLIGHT BEGIN ========= >>> AT > #{Time.now}"
    fetch_begin = Time.now
    destinationplaces = []

    session_keys = []
    results = []
    country = "JP"
    originplace = origin.airport_key
    adults = 1
    postURL = "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/v1.0"
    getURL = "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/uk2/v1.0"

    region.cities.each do |city|
      destinationplaces << city.airport_key
    end

    pool = Thread.pool([destinationplaces.size, 15].min)

    destinationplaces.each do |destination|
      pool.process {
        begin
          response = RestClient.post postURL, {
            "country" => country,
            "currency" => "USD",
            "locale" => "en-US",
            "originPlace" => originplace,
            "destinationPlace" => destination,
            "outboundDate" => outboundDate,
            "inboundDate" => inboundDate,
            "cabinClass" => "economy",
            "adults" => adults,
            "children" => 0,
            "infants" => 0,
            "includeCarriers" => "",
            "excludeCarriers" => "",
            "groupPricing" => "false"
          },
          headers = {
            "Content-Type" => "application/x-www-form-urlencoded",
            "X-Mashape-Key" => ENV["X_MASHAPE_KEY"],
            "X-Mashape-Host" => ENV["X_MASHAPE_HOST"]
            }
          session_keys << response.headers[:location].split("/").last
  
          p "================ FLIGHT PUSH = POOLinner >> #{Time.now - fetch_begin}"
        rescue => e
          p e
        end
      }
    end

    pool.shutdown

    pool = Thread.pool([session_keys.size, 15].min)

    get_origin = Time.now

    session_keys.each do |session_key|
      pool.process {
        response = RestClient.get "#{getURL}/#{session_key}",{
        "X-Mashape-Key" => ENV["X_MASHAPE_KEY"],
        "X-Mashape-Host" => ENV["X_MASHAPE_HOST"]
        }
        results << JSON.parse(response.body)
        p "================ FLIGHT GET = POOLinner >> #{Time.now - get_origin}"
      }
    end
    pool.shutdown

    puts "========== FETCH DATA FLIGHT END ========= >>> in > #{Time.now - fetch_begin} sec"
    fetch_begin = Time.now
    return results
  end
end
