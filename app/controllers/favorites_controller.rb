class FavoritesController < ApplicationController
  def create
    #code
    #....
    authorize(@favorite)
  end
  def index
    @favorites = policy_scope(Favorite).order(created_at: :desc)
  end
end
