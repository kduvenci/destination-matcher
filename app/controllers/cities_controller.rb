class CitiesController < ApplicationController
  skip_before_action :authenticate_user!, :verify_authorized, :verify_policy_scoped

end
