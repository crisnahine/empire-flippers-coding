require "rails_helper"

RSpec.describe Listing, type: :model do
  describe "validations" do
    it "is invalid without a listing_number" do
      listing = build(:listing, listing_number: nil)
      expect(listing).not_to be_valid
      expect(listing.errors[:listing_number]).to be_present
    end

    it "is invalid without a listing_status" do
      listing = build(:listing, listing_status: nil)
      expect(listing).not_to be_valid
      expect(listing.errors[:listing_status]).to be_present
    end

    it "is invalid with a duplicate listing_number" do
      create(:listing, listing_number: 99999)
      duplicate = build(:listing, listing_number: 99999)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:listing_number]).to be_present
    end

    it "is valid with required attributes" do
      expect(build(:listing)).to be_valid
    end
  end

  describe "scopes" do
    describe ".for_sale" do
      let!(:for_sale_listing) { create(:listing) }
      let!(:sold_listing)     { create(:listing, :sold) }

      it "returns only For Sale listings" do
        expect(Listing.for_sale).to contain_exactly(for_sale_listing)
      end
    end

    describe ".without_hubspot_deal" do
      let!(:listing_without_deal) { create(:listing) }
      let!(:listing_with_deal)    { create(:listing, :with_hubspot_deal) }

      it "returns only listings without a HubSpot deal ID" do
        expect(Listing.without_hubspot_deal).to contain_exactly(listing_without_deal)
      end
    end

    describe ".for_sale.without_hubspot_deal" do
      let!(:eligible)       { create(:listing) }
      let!(:sold)           { create(:listing, :sold) }
      let!(:already_synced) { create(:listing, :with_hubspot_deal) }

      it "returns only for-sale listings without a deal" do
        expect(Listing.for_sale.without_hubspot_deal).to contain_exactly(eligible)
      end
    end
  end
end
