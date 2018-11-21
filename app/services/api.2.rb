require 'thread'
require 'thread/pool'
require 'json'
require 'rest-client'
require 'pp'

pool = Thread.pool(3)

pool.process {  
  response = RestClient.post "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/v1.0", {
    "country" => "JP",
    "currency" => "USD",
    "locale" => "en-US",
    "originPlace" => "SFO-sky",
    "destinationPlace" => "LHR-sky",
    "outboundDate" => "2019-01-01",
    "inboundDate" => "2019-01-10",
    "cabinClass" => "business",
    "adults" => 1,
    "children" => 0,
    "infants" => 0,
    "includeCarriers" => "",
    "excludeCarriers" => "",
    "groupPricing" => "false"
  },
  headers = {
    "Content-Type" => "application/x-www-form-urlencoded",
    "X-Mashape-Key" => "NxHeqyNqVLmsh85DQkK6sKc4NZitp19PrEhjsnxGrrKE9eOv8f",
    "X-Mashape-Host" => "skyscanner-skyscanner-flight-search-v1.p.rapidapi.com"
  }
  p response.headers
}
pool.shutdown
