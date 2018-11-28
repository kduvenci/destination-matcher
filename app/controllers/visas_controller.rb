class VisasController < ApplicationController

  def show
    @visa = Visa.find(params[:id])
  end

end
