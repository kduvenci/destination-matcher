class FavoritesController < ApplicationController
  def index
    @favorites = policy_scope(Favorite).order(created_at: :desc)
  end

  def create
    @favorite = Favorite.new
    @user = current_user
    @flight = Flight.find(params[:flight_id])
    @accommodation = Accommodation.find(params[:accommodation_id])

    @favorite.user = @user
    @favorite.flight = @flight
    @favorite.accommodation = @accomodation

    authorize(@favorite)

    if @favorite.save
      redirect_to city_path(@flight.city)
    else
      render "cities/show"
    end
  end
end

