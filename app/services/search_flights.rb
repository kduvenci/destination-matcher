class SearchFlights
  # input:
  # {origin"=>"Tokyo", "region"=>"Asia", "min_budget"=>"500", "max_budget"=>"1000", "dep_date"=>"today", "return_date"=>"tomorrow", "commit"=>"Search"}

  # output:
  # [flight1, flight2...]
  def self.call(params)
    flights = []
    params[:region]
    flights
  end
end
