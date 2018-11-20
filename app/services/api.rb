require 'thread'
require 'thread/pool'
require 'json'
require 'rest-client'
require 'pp'

country = "JP"
currency = "USD"
locale = "en-US"
originplace = "NRT-sky"
# destinationplace = "JFK-sky"
outboundpartialdate = "2018-12-05"
inboundpartialdate = "2018-12-20"
urls = []
results = []

# create destinationplace accord. 'region' 
destinationplace = ["JFK-sky", "LIR-sky", "BOS-sky", "LCY-sky", "AMS-sky", "DME-sky"]

destinationplace = ["JFK-sky"]

destinationplace.each do |destination|
  url_head = 'https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/browseroutes/v1.0/'
  url_args = "#{country}/#{currency}/#{locale}/#{originplace}/#{destination}/#{outboundpartialdate}/#{inboundpartialdate}"
  urls << url_head + url_args
end

pp urls

pool = Thread.pool(3)

urls.each do |url|  
  pool.process {
    response = RestClient.get url, {
      "X-Mashape-Key" => "NxHeqyNqVLmsh85DQkK6sKc4NZitp19PrEhjsnxGrrKE9eOv8f",
      "X-Mashape-Host" => "skyscanner-skyscanner-flight-search-v1.p.rapidapi.com"
    }
    results << JSON.parse(response.body)
  }
end
pool.shutdown

pp results