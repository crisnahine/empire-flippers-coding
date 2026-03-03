class ListingsController < ApplicationController
  def index
    @pagy, @listings = pagy(Listing.all)
  end
end
