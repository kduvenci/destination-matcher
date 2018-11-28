# require 'thread'
# require 'thread/pool'
# require 'json'
# require 'rest-client'
# require 'pp'

# session_keys = []
# results = []
# country = "JP"
# originplace = "SFO-sky"
# outboundDate = "2019-01-01"
# inboundDate = "2019-01-10"
# adults = 1
# depart_departure_time = ""
# depart_arrival_time = ""
# depart_originID = ""
# depart_destinationID = ""
# return_departure_time = ""
# return_arrival_time = ""
# return_originID = ""
# return_destinationID = ""
# postURL = "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/v1.0"
# getURL = "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/uk2/v1.0"

# # destinationplace = ["JFK-sky", "LIR-sky", "BOS-sky", "LCY-sky", "AMS-sky", "DME-sky"]
# destinationplace = ["LHR-sky"]

# pool = Thread.pool(6)

# destinationplace.each do |destination|
#   pool.process {  
#     response = RestClient.post postURL, {
#       "country" => country,
#       "currency" => "USD",
#       "locale" => "en-US",
#       "originPlace" => originplace,
#       "destinationPlace" => destination,
#       "outboundDate" => outboundDate,
#       "inboundDate" => inboundDate,
#       "cabinClass" => "economy",
#       "adults" => adults,
#       "children" => 0,
#       "infants" => 0,
#       "includeCarriers" => "",
#       "excludeCarriers" => "",
#       "groupPricing" => "false"
#     },
#     headers = {
#       "Content-Type" => "application/x-www-form-urlencoded",
#       "X-Mashape-Key" => ENV["X_MASHAPE_KEY"],
#       "X-Mashape-Host" => ENV["X_MASHAPE_HOST"]
#     }
#     session_keys << response.headers[:location].split("/").last
#   }
# end
# pool.shutdown

# pool = Thread.pool(6)
# session_keys.each do |session_key|
#   # puts "by key => #{session_key}"
#   pool.process {
#     response = RestClient.get "#{getURL}/#{session_key}?pageIndex=0&pageSize=10",{
#         "X-Mashape-Key" => ENV["X_MASHAPE_KEY"],
#         "X-Mashape-Host" => ENV["X_MASHAPE_HOST"]
#     }
#     results << JSON.parse(response.body)
#   }
# end
# pool.shutdown

# results.each do |jsonHash|
#   jsonHash["Itineraries"].each do |itinerary|
#     # find Agent
#     agentId = itinerary["PricingOptions"].first["Agents"].first
#     agent = jsonHash["Agents"].select {|agent| agent["Id"] == agentId }
#     agent_name = agent.first["Name"]

#     # Booking URL and Price
#     deeplinkUrl = itinerary["PricingOptions"].first["DeeplinkUrl"]
#     price = itinerary["PricingOptions"].first["Price"]

    
#     jsonHash["Legs"].each do |leg|
#       if leg["Id"] == itinerary["OutboundLegId"]
#         depart_departure_time = leg["Departure"]
#         depart_arrival_time = leg["Arrival"]
#         depart_originID = leg["OriginStation"]
#         depart_destinationID = leg["DestinationStation"]
#       end
#       if leg["Id"] == itinerary["InboundLegId"]
#         return_departure_time = leg["Departure"]
#         return_arrival_time = leg["Arrival"]
#         return_originID = leg["OriginStation"]
#         return_destinationID = leg["DestinationStation"]
#       end
#     end

#     puts "#{agent_name} / #{price} $"
#     puts "#{depart_departure_time} / #{depart_arrival_time} - #{depart_originID} .. #{depart_destinationID}"
#     puts 
#     "#{return_departure_time} / #{return_arrival_time} - #{return_originID} .. #{return_destinationID}"
#     pp deeplinkUrl
#     puts "-----------------------------------------------------"

#     departure_location = ""
#     return_location = ""
#     airline_name = ""
#     created_at = ""
#     updated_at = ""
#     city_id = ""

#   end
#   puts "=============================================="
# end