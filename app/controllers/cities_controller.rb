class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @countries = Country.all
    @cities = City.all
    if params[:commit] == 'Search'
      @flightsAPI = FetchFlights.call(params[:region])
      pp "HEREEEE #{@flightsAPI}"
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
