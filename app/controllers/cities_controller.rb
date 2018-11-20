class CitiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, :verify_policy_scoped

  def index
    @flights = SearchFlights.call(params)
  end

  def show
    @city = City.find(params[:id])
  end
end
