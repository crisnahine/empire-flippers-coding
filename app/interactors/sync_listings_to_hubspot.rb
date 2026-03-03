class SyncListingsToHubspot
  include Interactor

  def call
    results = { created: 0, failed: 0 }

    Listing.for_sale.without_hubspot_deal.each do |listing|
      outcome = CreateHubspotDeal.call(listing: listing)

      if outcome.success?
        results[:created] += 1
      else
        results[:failed] += 1
        Rails.logger.error("HubSpot deal failed for listing ##{listing.listing_number}: #{outcome.error}")
      end
    end

    context.hubspot_results = results
  end
end
