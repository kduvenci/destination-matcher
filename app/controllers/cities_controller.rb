require 'thread'
require 'thread/pool'
class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @result_cities = []
    @messages = []
    if params[:commit] == 'Search'
      # prepare params for fetchflight and budget calc
      origin = City.find(params['/cities']['origin'])
      region = Region.find(params['/cities']['region'])
      outboundDate = params['/cities']["dep_date"]
      inboundDate = params['/cities']["return_date"]
      max_budget = params['/cities']["max_budget"].gsub(",","").gsub("$", "").strip.to_i
      
      # reject the origin city if city in the selected region
      destination_cities = region.cities.reject { |city| city == origin }

      # find travel period for budget calculation
      outDay = DateTime.new(outboundDate[0..3].to_i, outboundDate[5..6].to_i, outboundDate[8..9].to_i)
      inDay = DateTime.new(inboundDate[0..3].to_i, inboundDate[5..6].to_i, inboundDate[8..9].to_i)
      period = (inDay - outDay).to_i  

      # Call A scraping services
      fetch_begin = Time.now
      accom_service_response = []
      flight_service_response = []
      accommodation_pool = Thread.pool(15)

      FetchAccommodations.call(destination_cities, outboundDate, inboundDate, accommodation_pool, accom_service_response)
      FetchFlights.call(origin, destination_cities, outboundDate, inboundDate, flight_service_response)
      
      accommodation_pool.shutdown
      puts "====== FETCH DATA ACCOM END ====== >>> in > #{Time.now - fetch_begin} sec"

      # Save Accommodations
      @messages << "Accommodation data resource not available." if accom_service_response.empty?
      @messages << "Flight API resource not available." if flight_service_response.empty?

      if @messages.empty?
        saved_accoms = save_accommodation(accom_service_response)
        @messages << "Accommodation is not available for selected dates." if saved_accoms.empty?

        if @messages.empty?
          # Save Flights if in Bugdet
          save_flight_time = Time.now
          saved_flights = save_flights(flight_service_response, saved_accoms, max_budget, period)

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
      if @messages.present?
        puts "========== >>> ERROR MESSAGES <<< =========="
        @messages.each { |message| puts "-> #{message}" }
        puts "============================================"
      end  
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

    if params['flight_choice'].present?
      @flight = Flight.find(params['flight_choice'].to_i)
      @picked_flight = params['flight_choice'].to_i
    else
      @flight = @flights[0]
      @picked_flight = @flight.id
    end

    if params['accommodation_choice'].present?
      @accommodation = Accommodation.find(params['accommodation_choice'])
      @picked_accommodation = params['accommodation_choice']
    else
      @accommodation = @accommodations[0]
      @picked_accommodation = @accommodation.id
    end

    @meal = @flight.city.meal_average_price_cents;
    @period = ((@flight.return_arrival_time - @flight.depart_departure_time)/60/60/24).floor;
    @food = (@meal * 3 * @period).round
    @total = @food + @flight.price + @accommodation.price
  end

  def change_first_pick
    redirect_to controller: 'cities', action: 'show', id: params['city-id'], flight_ids: params['flight_ids'], accom_ids: params["accom_ids"], flight_choice: params['flight_choice'], accommodation_choice: params['accommodation_choice'], anchor: "flight"
  end

  def change_accom
    redirect_to controller: 'cities', action: 'show', id: params['city-id'], flight_ids: params['flight_ids'], accom_ids: params["accom_ids"], flight_choice: params['flight_choice'], accommodation_choice: params['accommodation_choice'], anchor: "accommodation"
  end

  private

  def save_flights(flight_service_response, saved_accoms, max_budget, period)
    # Get information from json objects
    saved_flights = []
    flight_service_response.each do |json_hash|
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
      
      # sort itineraries by price
      itineraries = json_hash["Itineraries"].sort! { |iti_a, iti_b| iti_a["PricingOptions"].first["Price"] <=> iti_b["PricingOptions"].first["Price"] }

      # iterate first 5 itinerary
      itineraries[0..4].each do |itinerary|
        # ticket general informations
        adults = json_hash["Query"]["Adults"]
        depart_code = json_hash["Places"].select { |place| place["Id"] == json_hash["Query"]["OriginPlace"].to_i }.first["Code"]
        return_code = json_hash["Places"].select { |place| place["Id"] == json_hash["Query"]["DestinationPlace"].to_i }.first["Code"]
        cabin_class = json_hash["Query"]["CabinClass"]
        deeplinkUrl = itinerary["PricingOptions"].first["DeeplinkUrl"]
        ticket_price = itinerary["PricingOptions"].first["Price"]

        # find agent
        agentId = itinerary["PricingOptions"].first["Agents"].first
        agent = json_hash["Agents"].select { |agent| agent["Id"] == agentId }
        agent_name = agent.first["Name"]

        # departure and arrival infos
        json_hash["Legs"].each do |leg|
          if leg["Id"] == itinerary["OutboundLegId"]
            depart_departure_time = leg["Departure"].to_time
            depart_arrival_time = leg["Arrival"].to_time
            depart_departure_placeID = leg["OriginStation"]
            depart_carrierID = leg["Carriers"].first
            depart_stops = leg["Stops"].size == 0 ? "Direct" : leg["Stops"].size
          end
          if leg["Id"] == itinerary["InboundLegId"]
            return_departure_time = leg["Departure"].to_time
            return_arrival_time = leg["Arrival"].to_time
            return_departure_placeID = leg["OriginStation"]
            return_carrierID = leg["Carriers"].first
            return_stops = leg["Stops"].size == 0 ? "Direct" : leg["Stops"].size
          end
        end

        # locations
        departure_location = json_hash["Places"].select { |place| place["Id"] == depart_departure_placeID }
        return_location = json_hash["Places"].select { |place| place["Id"] == return_departure_placeID }
        # airline company
        depart_carrier = json_hash["Carriers"].select { |carrier| carrier["Id"] == depart_carrierID }
        return_carrier = json_hash["Carriers"].select { |carrier| carrier["Id"] == return_carrierID }
        city = City.find_by(airport_key: "#{return_location[0]["Code"]}-sky")

        if in_bugget?(max_budget, ticket_price, city, saved_accoms, period)
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
            saved_flights << flight
          else
            p "= = > > Error during saving flight: #{flight.errors.messages} "
          end
        # else
        #   p "============================================================================="
        #   p "======= Ticket price: #{ticket_price}$ NOT IN BUGDET for #{city.name} ======="
        #   p "============================================================================="
        end
      end
    end

    return saved_flights
  end

  def save_accommodation(accom_service_response)
    savedAccommodations = []
    accom_service_response.each do |accoms_of_city|
      accoms_of_city.reject! { |elem| elem[:price].empty? }
      accoms_of_city.sort! { |a, b| a[:price] <=> b[:price] }
      accoms_of_city[0..4].each do |accom_hash|
        accommodation = Accommodation.new(
          city: City.find_by(name: accom_hash[:city]),
          name: accom_hash[:name],
          price: accom_hash[:price].gsub(",","").gsub("US$","").to_i,
          address: accom_hash[:address],
          photo: accom_hash[:image_url],
          booking_url: accom_hash[:booking_url],
          score: accom_hash[:score]
        )
        if accommodation.save
          savedAccommodations << accommodation
        else
          p "--- !!! Error Saving Accommodation !!! --->: #{accommodation.errors.messages}"
        end
      end
    end
    return savedAccommodations
  end

  def in_bugget?(max_budget, ticket_price, city, saved_accoms, period)
    accommodation_cost = saved_accoms.select { |accom| accom.city == city }.first.price rescue nil
    return false unless accommodation_cost.present?
    meal = city.meal_average_price_cents
    food = (meal * 3 * period).round
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
      accom_price = Accommodation.find(accom_id).price
      cost = food + accom_price + flight_price
      total_cost[city_info.first] = cost
    end
    total_cost
  end
end
