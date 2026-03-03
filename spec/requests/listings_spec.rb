require "rails_helper"

RSpec.describe "GET /listings", type: :request do
  def json
    JSON.parse(response.body)
  end

  context "when there are no listings" do
    it "returns 200 with empty data and pagination" do
      get "/listings"

      expect(response).to have_http_status(:ok)
      expect(json["data"]).to eq([])
      expect(json["pagination"]["count"]).to eq(0)
    end
  end

  context "when listings exist" do
    before { create_list(:listing, 3) }

    it "returns 200" do
      get "/listings"
      expect(response).to have_http_status(:ok)
    end

    it "returns data with expected fields" do
      get "/listings"

      item = json["data"].first
      expect(item).to include("listing_number", "listing_price", "listing_status", "summary")
    end

    it "returns pagination metadata" do
      get "/listings"

      pagination = json["pagination"]
      expect(pagination).to include("count", "page", "next", "prev", "last")
      expect(pagination["count"]).to eq(3)
      expect(pagination["page"]).to eq(1)
    end
  end

  context "with pagination" do
    before { create_list(:listing, 25) }

    it "respects the ?limit= param" do
      get "/listings", params: { limit: 5 }

      expect(json["data"].size).to eq(5)
      expect(json["pagination"]["last"]).to eq(5)
    end

    it "respects the ?page= param" do
      get "/listings", params: { limit: 5, page: 2 }

      expect(json["pagination"]["page"]).to eq(2)
      expect(json["pagination"]["prev"]).to eq(1)
      expect(json["pagination"]["next"]).to eq(3)
    end

    it "returns empty data for an out-of-range page" do
      get "/listings", params: { page: 9999 }

      expect(response).to have_http_status(:ok)
      expect(json["data"]).to eq([])
    end

    it "defaults to 20 items per page" do
      get "/listings"

      expect(json["data"].size).to eq(20)
      expect(json["pagination"]["last"]).to eq(2)
    end
  end
end
