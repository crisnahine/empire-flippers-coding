class UpsertListings
  include Interactor

  before do
    context.fail!(error: "raw_listings is required") if context.raw_listings.nil?
  end

  def call
    return context.upserted_count = 0 if context.raw_listings.empty?

    records = context.raw_listings.map do |d|
      {
        listing_number: d["listing_number"],
        listing_price:  d["listing_price"],
        listing_status: d["listing_status"],
        summary:        d["summary"]
      }
    end

    result = Listing.upsert_all(
      records,
      unique_by:   :listing_number,
      update_only: %i[listing_price listing_status summary]
    )

    context.upserted_count = result.length
  end
end
