class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    # raise
    if params[:origin].present?
      # raise
      @flights = SearchFlights.call(params)
      raise
      # @flights = Flight.search(params[:query])
      # @accomodations = Accomodation.seach(params[:query])
    else
      # @cities = City.all
    end
  end

  def show
    @city = City.find(params[:id])
  end
end
