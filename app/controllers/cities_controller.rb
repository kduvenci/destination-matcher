class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @cities = City.all
    if params[:commit] == 'Search'
      # prepare params for FetchFlights
      origin = City.find(params['/cities']['origin'])
      region = Region.find(params['/cities']['region'])
      outboundDate = params['/cities']["dep_date"]
      inboundDate = params['/cities']["return_date"]
      min_budget = params['/cities']["min_budget"].gsub(" USD", "").gsub(",","").to_i
      max_budget = params['/cities']["max_budget"].gsub(" USD", "").gsub(",","").to_i

      # Call service
      @flightsAPI = FetchFlights.call(origin, region, outboundDate, inboundDate)

      # Get information from json objects
      @cost_range = []
      @savedFlights = []
      @flightsAPI.each do |jsonHash|
        depart_departure_time = ""
        depart_arrival_time = ""
        depart_originID = ""
        depart_destinationID = ""
        depart_departure_placeID = ""
        depart_arrival_placeID = ""
        depart_carrierID = ""

        return_departure_time = ""
        return_arrival_time = ""
        return_originID = ""
        return_destinationID = ""
        return_departure_placeID = ""
        return_arrival_placeID = ""
        return_carrierID = ""

        departure_location = ""
        return_location = ""
        airline_name = ""
        created_at = ""
        updated_at = ""
        city_id = ""

        jsonHash["Itineraries"].each do |itinerary|
          # find Agent
          agentId = itinerary["PricingOptions"].first["Agents"].first
          agent = jsonHash["Agents"].select {|agent| agent["Id"] == agentId }
          agent_name = agent.first["Name"]

          # Booking URL and Price
          deeplinkUrl = itinerary["PricingOptions"].first["DeeplinkUrl"]
          price = itinerary["PricingOptions"].first["Price"]

          # Booking URL and Price
          jsonHash["Legs"].each do |leg|
            if leg["Id"] == itinerary["OutboundLegId"]
              depart_departure_time = leg["Departure"]
              depart_arrival_time = leg["Arrival"]
              depart_departure_placeID = leg["OriginStation"]
              depart_arrival_placeID = leg["DestinationStation"]
              depart_carrierID = leg["Carriers"].first
              depart_originID = leg["OriginStation"]
              depart_destinationID = leg["DestinationStation"]
            end
            if leg["Id"] == itinerary["InboundLegId"]
              return_departure_time = leg["Departure"]
              return_arrival_time = leg["Arrival"]
              return_departure_placeID = leg["OriginStation"]
              return_arrival_placeID = leg["DestinationStation"]
              return_carrierID = leg["Carriers"].first
              return_originID = leg["OriginStation"]
              return_destinationID = leg["DestinationStation"]
            end
          end

          departure_location = jsonHash["Places"].select {|place| place["Id"] == depart_departure_placeID }
          return_location = jsonHash["Places"].select {|place| place["Id"] == return_departure_placeID }

          depart_carrier = jsonHash["Carriers"].select {|carrier| carrier["Id"] == depart_carrierID }
          return_carrier = jsonHash["Carriers"].select {|carrier| carrier["Id"] == return_carrierID }

          flight = Flight.new(
            depart_departure_time: depart_departure_time.to_time,
            depart_arrival_time: depart_arrival_time.to_time,
            return_departure_time: return_departure_time.to_time,
            return_arrival_time: return_arrival_time.to_time,
            departure_location: departure_location[0]["Name"],
            return_location: return_location[0]["Name"],
            price: price,
            city: City.find_by(airport_key: "#{return_location[0]["Code"]}-sky"),
            airline_name: depart_carrier[0]["Name"]
          )

          if flight.save!
            @savedFlights << flight
          else
            p "= = > > Error durin saving flight: #{flight.errors.messages} "
          end
        end
      end

      @savedFlights.sort { |a, b| a.price <=> b.price }
      @cities = [@savedFlights.first.city]
      ## BUGDET CALCULATION
      # @savedFlights.each do |flight|
      #   meal = flight.city.meal_average_price_cents;
      #   period = ((flight.return_arrival_time - flight.depart_departure_time)/60/60/24).floor;
      #   accommodation = period * 100
      #   total = meal * 3 * period + flight.price + accommodation

      #   if total >= min_budget && total <= max_budget
      #     @cost_range << {
      #       flight_id: flight.id,
      #       meal: meal,
      #       period: period,
      #       food: meal * 3 * period,
      #       ticket: flight.price,
      #       accommodation: accommodation,
      #       total: total
      #     }
      #   end
      #   @cities = []
      #   @cost_range.each do |flight_set|
      #     flight = Flight.find(flight_set[:flight_id])
      #     @cities << flight.city unless @cities.include?(flight.city)
      #   end
      # end

    end
  end

  def show
    @city = City.find(params[:id])
  end
end
