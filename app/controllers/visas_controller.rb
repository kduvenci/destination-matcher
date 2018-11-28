class VisasController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def search
    @visa = Visa.find(params[:id])
    authorize @visa
    @relationship = eval(@visa.relationship)
    @destination = params[:destination]
    @result = @relationship[@destination]
  end
end
