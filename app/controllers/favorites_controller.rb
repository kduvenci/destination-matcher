class FavoritesController < ApplicationController
  def create
    @favorite = Favorite.new
    @user = current_user
    @flight = Flight.find(params[:id])
    @accomodation = Accommodation.find(params[:id])

    @favorite.user = @user
    @favorite.flight = @flight
    @favorite.accommodation = @accomodation

    authorize(@favorite)

    @favorite.save!
  end

  def index
    @favorites = policy_scope(Favorite).order(created_at: :desc)
  end
end
