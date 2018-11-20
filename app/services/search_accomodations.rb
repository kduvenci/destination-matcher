class SearchAccomodations
  def self.call(params)
    accommodations = Accommodation.all
    accommodations = accommodations.where(city: params[:region]) if params[:region]
    accommodations = accommodations.where("price >= ?", params[:min_budget]) if params[:min_budget]
    accommodations = accommodations.where("price <= ?", params[:max_budget]) if  params[:max_budget]
    return accommodations
  end
end
