require "rails_helper"

RSpec.describe UpsertListings do
  let(:raw_listings) do
    [
      { "listing_number" => 11111, "listing_price" => 75_000.0, "listing_status" => "For Sale", "summary" => "Listing one" },
      { "listing_number" => 22222, "listing_price" => 120_000.0, "listing_status" => "Sold", "summary" => "Listing two" }
    ]
  end

  describe "#call" do
    context "when raw_listings is nil" do
      it "fails the context via the before hook" do
        result = described_class.call(raw_listings: nil)
        expect(result).to be_failure
        expect(result.error).to eq("raw_listings is required")
      end
    end

    context "when raw_listings is empty" do
      it "succeeds and sets upserted_count to 0" do
        result = described_class.call(raw_listings: [])
        expect(result).to be_success
        expect(result.upserted_count).to eq(0)
        expect(Listing.count).to eq(0)
      end
    end

    context "with valid raw_listings" do
      it "creates records in the database" do
        expect { described_class.call(raw_listings: raw_listings) }
          .to change(Listing, :count).by(2)
      end

      it "sets upserted_count" do
        result = described_class.call(raw_listings: raw_listings)
        expect(result.upserted_count).to eq(2)
      end

      it "persists the correct field values" do
        described_class.call(raw_listings: raw_listings)
        listing = Listing.find_by(listing_number: 11111)
        expect(listing.listing_price).to eq(75_000.0)
        expect(listing.listing_status).to eq("For Sale")
      end
    end

    context "when a listing already exists with a hubspot_deal_id" do
      let!(:existing) { create(:listing, listing_number: 11111, hubspot_deal_id: "existing-deal-id") }

      it "does not overwrite the existing hubspot_deal_id on upsert" do
        described_class.call(raw_listings: raw_listings)
        expect(existing.reload.hubspot_deal_id).to eq("existing-deal-id")
      end

      it "does update the price on upsert" do
        described_class.call(raw_listings: raw_listings)
        expect(existing.reload.listing_price).to eq(75_000.0)
      end
    end
  end
end
