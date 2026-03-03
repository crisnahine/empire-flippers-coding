class SyncListingsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("SyncListingsJob: starting")
    result = SyncListings.call

    if result.success?
      Rails.logger.info("SyncListingsJob: done. Upserted #{result.upserted_count}, HubSpot #{result.hubspot_results}")
    else
      Rails.logger.error("SyncListingsJob failed — #{result.error}")
      raise result.error
    end
  end
end
