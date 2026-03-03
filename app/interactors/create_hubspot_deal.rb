require "hubspot/codegen/crm/deals/api_error"

class CreateHubspotDeal
  include Interactor

  CLOSE_DATE_DAYS = 30

  before do
    context.fail!(error: "listing is required") if context.listing.nil?
  end

  def call
    listing  = context.listing
    api      = HubspotConfig.client.crm.deals.basic_api
    response = api.create(
      body: {
        properties: {
          dealname:    "Listing #{listing.listing_number}",
          amount:      listing.listing_price.to_s,
          closedate:   ((Time.now + CLOSE_DATE_DAYS.days).to_i * 1000).to_s,
          description: listing.summary
        }
      }
    )

    listing.update!(hubspot_deal_id: response.id)
  rescue Hubspot::Crm::Deals::ApiError => e
    context.fail!(error: "HubSpot API error: #{e.message}")
  end
end
