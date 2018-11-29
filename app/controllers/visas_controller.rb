class VisasController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def search
    if params[:id].present?
      @visa = Visa.find(params[:id])
      authorize @visa
      @relationship = eval(@visa.relationship)
      @destination = params[:destination]
      @result = @relationship[@destination]
    else
      @result = "Pick an option above"
    end
  end
end
