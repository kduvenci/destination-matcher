require 'thread'
require 'thread/pool'
require 'json'
require 'rest-client'
require 'pp'

class FetchFlights
  def self.call(origin, region, outboundDate, inboundDate)
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
    
    pool = Thread.pool(6)
    
    destinationplaces.each do |destination|
      pool.process {  
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
      }
    end
    pool.shutdown
    
    pool = Thread.pool(6)
    session_keys.each do |session_key|
      # puts "by key => #{session_key}"
      pool.process {
        response = RestClient.get "#{getURL}/#{session_key}?pageIndex=0&pageSize=10",{
        "X-Mashape-Key" => ENV["X_MASHAPE_KEY"],
        "X-Mashape-Host" => ENV["X_MASHAPE_HOST"]
        }
        results << JSON.parse(response.body)
      }
    end
    pool.shutdown
    return results
  end
end