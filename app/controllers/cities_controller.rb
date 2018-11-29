require 'thread'
require 'thread/pool'
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
      max_budget = params['/cities']["max_budget"].gsub(",","").gsub(" US$", "").to_i

      # Call api & scraping services
      # pool = Thread.pool(1)
      # pool.process {
        flightsAPI = FetchFlights.call(origin, region, outboundDate, inboundDate)
        accommodationsAPI = FetchAccommodations.call(region, outboundDate, inboundDate)
      # }
      # pool.shutdown

      # Save Flights if in Bugdet
      save_flight_time = Time.now
      saved_accoms = save_accommodation(accommodationsAPI)
      saved_flights = save_flights(flightsAPI, max_budget, saved_accoms)

      # prepare city array and city flight pairs
      cf_id_array = []
      saved_flights.each do |flight|
        @result_cities << flight.city unless @result_cities.include?(flight.city)
        cf_id_array << {
          city_id: flight.city.id,
          flight_id: flight.id
        }
      end

      # prepare city accom. pairs
      ca_id_array = []
      saved_accoms.each do |accom|
        ca_id_array << {
          city_id: accom.city.id,
          accom_id: accom.id
        }
      end

      # prepare list for view
      @result_cities = @result_cities.map do |city|
        [ city,
          cf_id_array.select { |pair| pair[:city_id] == city.id }.map { |pair| pair[:flight_id] },
          ca_id_array.select { |pair| pair[:city_id] == city.id }.map { |pair| pair[:accom_id] }
        ]
      end

      # prepare cost list by city
      @total_cost =  prepare_cost_for_index(@result_cities)
    end
  end

  def show
    @city = City.find(params[:id])
    @flights = []
    @accommodations = []
    #prepare flight instances
    @flights_ids = params["flight_ids"].split("-")
    @flights_ids.each do |id|
      @flights << Flight.find(id)
    end
    @flights = @flights.sort { |a, b| a.price <=> b.price }

    #prepare accommodation instances
    @accom_ids = params["accom_ids"].split("-")
    @accom_ids.each do |id|
      @accommodations << Accommodation.find(id)
    end
    @accommodations = @accommodations.sort { |a, b| a.price <=> b.price }

    if params['flight_choice']
      @flight = Flight.find(params['flight_choice'].to_i)
      @picked_flight = params['flight_choice'].to_i
    else
      @flight = @flights[0]
      @picked_flight = @flight.id
    end

    if params['accommodation_choice']
      @accommodation = Accommodation.find(params['accommodation_choice'])
      @picked_accommodation = params['accommodation_choice']
    else
      @accommodation = @accommodations[0]
      @picked_accommodation = @accommodation.id
    end

    @meal = @flight.city.meal_average_price_cents;
    @period = ((@flight.return_arrival_time - @flight.depart_departure_time)/60/60/24).floor;
    @food = (@meal * 3 * @period).round
    @total = @food + @flight.price + @accommodation.price * @period
  end

  def change_first_pick
    redirect_to controller: 'cities', action: 'show', id: params['city-id'], flight_ids: params['flight_ids'], accom_ids: params["accom_ids"], flight_choice: params['flight_choice'], anchor: "flight"
  end

  def change_accom
    redirect_to controller: 'cities', action: 'show', id: params['city-id'], flight_ids: params['flight_ids'], accom_ids: params["accom_ids"], accommodation_choice: params['accommodation_choice'], anchor: "accommodation"
  end

  private

  def save_flights(flightsAPI, max_budget, saved_accoms)
    # from result max how much ticket will should save
    save_max_flight = 150

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
      depart_stops = ""
      depart_code = ""

      return_departure_time = ""
      return_arrival_time = ""
      return_originID = ""
      return_destinationID = ""
      return_departure_placeID = ""
      return_arrival_placeID = ""
      return_carrierID = ""
      return_stops = ""
      return_code = ""

      departure_location = ""
      return_location = ""
      counter = 0

      jsonHash["Itineraries"].each do |itinerary|
        if counter < save_max_flight
          # ticket general informations
          adults = jsonHash["Query"]["Adults"]
          depart_code = jsonHash["Places"].select { |place| place["Id"] == jsonHash["Query"]["OriginPlace"].to_i }.first["Code"]
          return_code = jsonHash["Places"].select { |place| place["Id"] == jsonHash["Query"]["DestinationPlace"].to_i }.first["Code"]
          cabin_class = jsonHash["Query"]["CabinClass"]
          deeplinkUrl = itinerary["PricingOptions"].first["DeeplinkUrl"]
          ticket_price = itinerary["PricingOptions"].first["Price"]

          # find agent
          agentId = itinerary["PricingOptions"].first["Agents"].first
          agent = jsonHash["Agents"].select { |agent| agent["Id"] == agentId }
          agent_name = agent.first["Name"]

          # departure and arrival infos
          jsonHash["Legs"].each do |leg|
            if leg["Id"] == itinerary["OutboundLegId"]
              depart_departure_time = leg["Departure"].to_time
              depart_arrival_time = leg["Arrival"].to_time
              depart_departure_placeID = leg["OriginStation"]
              # depart_arrival_placeID = leg["DestinationStation"]
              depart_carrierID = leg["Carriers"].first
              depart_stops = leg["Stops"].size == 0 ? "Direct" : leg["Stops"].size
            end
            if leg["Id"] == itinerary["InboundLegId"]
              return_departure_time = leg["Departure"].to_time
              return_arrival_time = leg["Arrival"].to_time
              return_departure_placeID = leg["OriginStation"]
              # return_arrival_placeID = leg["DestinationStation"]
              return_carrierID = leg["Carriers"].first
              return_stops = leg["Stops"].size == 0 ? "Direct" : leg["Stops"].size
            end
          end

          # locations
          departure_location = jsonHash["Places"].select { |place| place["Id"] == depart_departure_placeID }
          return_location = jsonHash["Places"].select { |place| place["Id"] == return_departure_placeID }
          # airline company
          depart_carrier = jsonHash["Carriers"].select { |carrier| carrier["Id"] == depart_carrierID }
          return_carrier = jsonHash["Carriers"].select { |carrier| carrier["Id"] == return_carrierID }
          city = City.find_by(airport_key: "#{return_location[0]["Code"]}-sky")

          if in_bugget?(max_budget, ticket_price, city, return_arrival_time, depart_departure_time, saved_accoms)
            # prepare flight instances
            flight = Flight.new(
              # general
              adults: adults,
              agent: agent_name,
              cabin_class: cabin_class,
              price: ticket_price,
              booking_url: deeplinkUrl,
              city: city,
              # depart info
              depart_airline_name: depart_carrier[0]["Name"],
              departure_location: departure_location[0]["Name"],
              depart_departure_time: depart_departure_time,
              depart_arrival_time: depart_arrival_time,
              depart_stops: depart_stops,
              depart_code: depart_code,
              depart_image_url: depart_carrier[0]["ImageUrl"],
              # return info
              return_airline_name: return_carrier[0]["Name"],
              return_location: return_location[0]["Name"],
              return_departure_time: return_departure_time,
              return_arrival_time: return_arrival_time,
              return_stops: return_stops,
              return_code: return_code,
              return_image_url: return_carrier[0]["ImageUrl"]
            )

            # save flights
            if flight.save!
              savedFlights << flight
            else
              p "= = > > Error during saving flight: #{flight.errors.messages} "
            end
          end
        end
        counter += 1
      end
    end

    return savedFlights.sort { |a, b| a.price <=> b.price }
  end

  def save_accommodation(accommodationsAPI)
    savedAccommodations = []
    accommodationsAPI.each do |accCity|
      accCity.each do |accommodation|
        accommodation = Accommodation.new(
          city: City.find_by(name: accommodation[:city]),
          name: accommodation[:name],
          price: accommodation[:price].gsub(",","").gsub("US$","").to_i,
          address: accommodation[:address],
          photo: accommodation[:image_url],
          booking_url: accommodation[:booking_url],
          score: accommodation[:score]
        )
        if accommodation.save
          savedAccommodations << accommodation
        else
          p "= = > > Error during saving accommodation: #{accommodation.errors.messages} "
        end
      end
    end
    return savedAccommodations.sort { |a, b| a.price <=> b.price }
  end

  def in_bugget?(max_budget, ticket_price, city, return_arrival_time, depart_departure_time, saved_accoms)
    period = ((return_arrival_time - depart_departure_time)/60/60/24).floor
    meal = city.meal_average_price_cents
    food = (meal * 3 * period).round
    accommodation_cost = saved_accoms.select {|a| a.city == city }.sort { |a, b| a.price <=> b.price }.first.price
    total = food + ticket_price + accommodation_cost
    # pp "Food = #{food}, Acc = #{accommodation_cost}, Fly = #{ticket_price}, T = #{total}, B = #{max_budget}"
    return total <= max_budget
  end

  def prepare_cost_for_index(result_cities)
    total_cost = {}
    result_cities.each do |city_info|
      flight_id = city_info.second.first
      flight = Flight.find(flight_id)
      flight_price = flight.price
      meal = flight.city.meal_average_price_cents;
      period = ((flight.return_arrival_time - flight.depart_departure_time)/60/60/24).floor;
      food = (meal * 3 * period).round
      accom_id = city_info.third.first
      accom_price = Accommodation.find(accom_id).price * period
      cost = food + accom_price + flight_price
      total_cost[city_info.first] = cost
    end
    total_cost
  end
end
