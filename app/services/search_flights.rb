class SearchFlights
  # input:
  # {origin"=>"Tokyo", "region"=>"Asia", "min_budget"=>"500", "max_budget"=>"1000", "dep_date"=>"today", "return_date"=>"tomorrow", "commit"=>"Search"}

  # output:
  # [flight1, flight2...]
  def self.call(params)
    flights = Flight.all
    flights = flights.where(departure_location: params[:origin]) if params[:origin]
    flights = flights.where(return_location: params[:region]) if params[:region]
    flights = flights.where("price >= ?", params[:min_budget]) if params[:min_budget]
    flights = flights.where("price <= ?", params[:max_budget]) if  params[:max_budget]
    flights = flights.where(depart_departure_time: params[:dep_date]) if params[:dep_date]
    flights = flights.where(return_departure_time: params[:return_date]) if params[:return_date]
    return flights
  end
end

    # depart_departure_time: Time.now,
    # depart_arrival_time: Time.now,
    # return_departure_time: Time.now,
    # return_arrival_time: Time.now,
    # departure_location: city_names[counter],
    # return_location: city_names[counter],
    # price: 1000,
    # city: cities[counter],
    # airline_name: airline_names[counter])
