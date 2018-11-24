class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @result_cities = []
    if params[:commit] == 'Search'
      # prepare params for fetchflight and budget calc
      origin = City.find(params['/cities']['origin'])
      region = Region.find(params['/cities']['region'])
      outboundDate = params['/cities']["dep_date"]
      inboundDate = params['/cities']["return_date"]
      min_budget = params['/cities']["min_budget"].gsub(" USD", "").gsub(",","").to_i
      max_budget = params['/cities']["max_budget"].gsub(" USD", "").gsub(",","").to_i

      # Call service
      fetchTime = Time.now
      flightsAPI = FetchFlights.call(origin, region, outboundDate, inboundDate)
      
      # Save Flights if in Bugdet
      save_flight_time = Time.now
      saved_flights = save_flights(flightsAPI, max_budget)

      # prepare city array from flights
      cf_id_array = []
      saved_flights.each do |flight|
        @result_cities << flight.city unless @result_cities.include?(flight.city)
        cf_id_array << {
          city_id: flight.city.id,
          flight_id: flight.id
        }
      end

      # prepare list for view
      @result_cities = @result_cities.map do |city|
        [ city,
          cf_id_array.select { |pair| pair[:city_id] == city.id }.map { |pair| pair[:flight_id] }
        ]
      end
      puts "========== FETCH DATA COMPLETED ============ >>> in > #{save_flight_time - fetchTime} sec"
      puts "========== SAVE FLIGHTS COMPLETED ============ >>> in > #{Time.now - save_flight_time} sec"
    end
  end

  def show
    @city = City.find(params[:id])
    @flights = []
    @flights_ids = params["flight_ids"].split("-")
    @flights_ids.each do |id|
      @flights << Flight.find(id)
    end
    @flights = @flights.sort { |a, b| a.price <=> b.price }
    @flight = @flights.first
    @meal = @flight.city.meal_average_price_cents;
    @period = ((@flight.return_arrival_time - @flight.depart_departure_time)/60/60/24).floor;
    @food = @meal * 3 * @period
    @accommodations = @city.accommodations
    @accommodation = @accommodations.first
    @total = @food + @flight.price + @accommodation.price * @period
  end

  private

  def save_flights(flightsAPI, max_budget)
    # from result max how much ticket will should save
    save_max_flight = 8

    # Get information from json objects
    savedFlights = []
    flightsAPI.each do |jsonHash|
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
      counter = 0
      jsonHash["Itineraries"].each do |itinerary|
        if counter < save_max_flight
          # Booking URL and Price
          deeplinkUrl = itinerary["PricingOptions"].first["DeeplinkUrl"]
          ticket_price = itinerary["PricingOptions"].first["Price"]

          # find Agent
          agentId = itinerary["PricingOptions"].first["Agents"].first
          agent = jsonHash["Agents"].select {|agent| agent["Id"] == agentId }
          agent_name = agent.first["Name"]

          # Departure and Arrival Infos
          jsonHash["Legs"].each do |leg|
            if leg["Id"] == itinerary["OutboundLegId"]
              depart_departure_time = leg["Departure"].to_time
              depart_arrival_time = leg["Arrival"].to_time
              depart_departure_placeID = leg["OriginStation"]
              depart_arrival_placeID = leg["DestinationStation"]
              depart_carrierID = leg["Carriers"].first
              depart_originID = leg["OriginStation"]
              depart_destinationID = leg["DestinationStation"]
            end
            if leg["Id"] == itinerary["InboundLegId"]
              return_departure_time = leg["Departure"].to_time
              return_arrival_time = leg["Arrival"].to_time
              return_departure_placeID = leg["OriginStation"]
              return_arrival_placeID = leg["DestinationStation"]
              return_carrierID = leg["Carriers"].first
              return_originID = leg["OriginStation"]
              return_destinationID = leg["DestinationStation"]
            end
          end

          departure_location = jsonHash["Places"].select { |place| place["Id"] == depart_departure_placeID }
          return_location = jsonHash["Places"].select { |place| place["Id"] == return_departure_placeID }
          depart_carrier = jsonHash["Carriers"].select { |carrier| carrier["Id"] == depart_carrierID }
          return_carrier = jsonHash["Carriers"].select { |carrier| carrier["Id"] == return_carrierID }
          city = City.find_by(airport_key: "#{return_location[0]["Code"]}-sky")

          if in_bugget?(max_budget, ticket_price, city, return_arrival_time, depart_departure_time)
            # prepare flight instances
            flight = Flight.new(
              depart_departure_time: depart_departure_time,
              depart_arrival_time: depart_arrival_time,
              return_departure_time: return_departure_time,
              return_arrival_time: return_arrival_time,
              departure_location: departure_location[0]["Name"],
              return_location: return_location[0]["Name"],
              price: ticket_price,
              city: city,
              airline_name: depart_carrier[0]["Name"]
            )
            
            # save flights
            if flight.save!
              savedFlights << flight
            else
              p "= = > > Error durin saving flight: #{flight.errors.messages} "
            end
          end
        end
        counter += 1
      end
    end

    return savedFlights.sort { |a, b| a.price <=> b.price }  
  end

  def in_bugget?(max_budget, ticket_price, city, return_arrival_time, depart_departure_time)
    period = ((return_arrival_time - depart_departure_time)/60/60/24).floor;
    meal = city.meal_average_price_cents;
    food = meal * 3 * period
    accommodation = city.accommodations.first
    accommodation_cost = accommodation.price * period
    total = food + ticket_price + accommodation_cost
  
    return total <= max_budget
  end

end
