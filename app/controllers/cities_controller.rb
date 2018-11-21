class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @countries = Country.all
    @cities = City.all

    if params[:commit] == 'Search'
      @flightsAPI = FetchFlights.call(params[:region])

      depart_departure_time = ""
      depart_arrival_time = ""
      depart_originID = ""
      depart_destinationID = ""
      return_departure_time = ""
      return_arrival_time = ""
      return_originID = ""
      return_destinationID = ""
      departure_location = ""
      return_location = ""
      airline_name = ""
      created_at = ""
      updated_at = ""
      city_id = ""

      @flightsAPI.each do |jsonHash|
        jsonHash["Itineraries"].each do |itinerary|
          # find Agent
          agentId = itinerary["PricingOptions"].first["Agents"].first
          agent = jsonHash["Agents"].select {|agent| agent["Id"] == agentId }
          agent_name = agent.first["Name"]
      
          # Booking URL and Price
          deeplinkUrl = itinerary["PricingOptions"].first["DeeplinkUrl"]
          price = itinerary["PricingOptions"].first["Price"]      

          jsonHash["Legs"].each do |leg|
            if leg["Id"] == itinerary["OutboundLegId"]
              depart_departure_time = leg["Departure"]
              depart_arrival_time = leg["Arrival"]
              depart_originID = leg["OriginStation"]
              depart_destinationID = leg["DestinationStation"]
            end
            if leg["Id"] == itinerary["InboundLegId"]
              return_departure_time = leg["Departure"]
              return_arrival_time = leg["Arrival"]
              return_originID = leg["OriginStation"]
              return_destinationID = leg["DestinationStation"]
            end
          end
          puts "#{agent_name} / #{price} $"
          puts "#{depart_departure_time} / #{depart_arrival_time} - #{depart_originID} .. #{depart_destinationID}"
          puts "#{return_departure_time} / #{return_arrival_time} - #{return_originID} .. #{return_destinationID}"
          puts "-----------------------------------------------------"      
        end
        puts "=============================================="
      end
  
    end

    # Parameters: {"utf8"=>"✓", "origin"=>"Tokyo", "region"=>"Europe",
    #   "min_budget"=>"2000", "max_budget"=>"2500",
    #   "dep_date"=>"20.12.2018", "return_date"=>"10.01.2019",
    #   "commit"=>"Search"}

    @flightsDB = SearchFlights.call(params)
    @accommodationsDB = SearchAccomodations.call(params)
  end

  def show
    @city = City.find(params[:id])
  end
end
