require "rails_helper"

RSpec.describe FetchEmpireFlippersListings do
  subject(:interactor) { described_class.new }

  let(:base_url) { "https://api.empireflippers.com/api/v1/listings/list" }

  let(:listing_data) do
    {
      "listing_number" => 12345,
      "listing_price"  => 50_000.0,
      "listing_status" => "For Sale",
      "summary"        => "A profitable SaaS business"
    }
  end

  def api_response(listings:, page: 1, pages: 1)
    { "data" => { "listings" => listings, "page" => page, "pages" => pages } }.to_json
  end

  def stub_page(page_num, listings:, total_pages:)
    stub_request(:get, base_url)
      .with(query: { "page" => page_num.to_s, "limit" => "100" })
      .to_return(
        status:  200,
        body:    api_response(listings: listings, page: page_num, pages: total_pages),
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe "#call" do
    context "when the API returns a single page" do
      before { stub_page(1, listings: [ listing_data, listing_data ], total_pages: 1) }

      it "returns context success" do
        result = described_class.call
        expect(result).to be_success
      end

      it "sets raw_listings in context" do
        result = described_class.call
        expect(result.raw_listings.size).to eq(2)
        expect(result.raw_listings.first["listing_number"]).to eq(12345)
      end

      it "makes exactly one HTTP request" do
        described_class.call
        expect(WebMock).to have_requested(:get, /#{Regexp.escape(base_url)}/).once
      end
    end

    context "when the API returns multiple pages" do
      before do
        stub_page(1, listings: Array.new(3) { listing_data }, total_pages: 2)
        stub_page(2, listings: [ listing_data ], total_pages: 2)
        allow(interactor).to receive(:sleep)
      end

      it "fetches all pages and returns combined results" do
        result = described_class.call
        expect(result.raw_listings.size).to eq(4)
      end

      it "makes one request per page" do
        described_class.call
        expect(WebMock).to have_requested(:get, /#{Regexp.escape(base_url)}/).twice
      end
    end

    context "when the API returns an empty listings array" do
      before do
        stub_page(1, listings: [], total_pages: 1)
      end

      it "sets raw_listings to an empty array" do
        result = described_class.call
        expect(result.raw_listings).to eq([])
      end
    end

    context "when the API returns an HTTP error" do
      before do
        stub_request(:get, base_url)
          .with(query: { "page" => "1", "limit" => "100" })
          .to_return(status: 429, body: "Too Many Requests")
      end

      it "fails the context" do
        result = described_class.call
        expect(result).to be_failure
        expect(result.error).to include("429")
      end
    end

    context "when the API returns invalid JSON" do
      before do
        stub_request(:get, base_url)
          .with(query: { "page" => "1", "limit" => "100" })
          .to_return(status: 200, body: "not valid json")
      end

      it "fails the context" do
        result = described_class.call
        expect(result).to be_failure
        expect(result.error).to include("Failed to fetch listings")
      end
    end
  end
end
