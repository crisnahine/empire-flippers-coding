require "rails_helper"

RSpec.describe CreateHubspotDeal do
  let(:listing) { create(:listing, listing_number: 12345, listing_price: 50_000.00) }
  let(:api_double) { instance_double("Hubspot::Discovery::Crm::Deals::BasicApi") }
  let(:response_double) { double("HubspotDealResponse", id: "99887766") }
  let(:hubspot_client_double) { double("HubspotClient") }
  let(:crm_double)   { double("crm") }
  let(:deals_double) { double("deals") }

  before do
    allow(HubspotConfig).to receive(:client).and_return(hubspot_client_double)
    allow(hubspot_client_double).to receive(:crm).and_return(crm_double)
    allow(crm_double).to receive(:deals).and_return(deals_double)
    allow(deals_double).to receive(:basic_api).and_return(api_double)
  end

  describe "#call" do
    context "when listing is nil" do
      it "fails the context via the before hook" do
        result = described_class.call(listing: nil)
        expect(result).to be_failure
        expect(result.error).to eq("listing is required")
      end
    end

    context "with a valid listing" do
      before do
        allow(api_double).to receive(:create).and_return(response_double)
      end

      it "returns a successful context" do
        result = described_class.call(listing: listing)
        expect(result).to be_success
      end

      it "saves the HubSpot deal ID on the listing" do
        described_class.call(listing: listing)
        expect(listing.reload.hubspot_deal_id).to eq("99887766")
      end

      it "calls the HubSpot API with correct properties" do
        described_class.call(listing: listing)

        expect(api_double).to have_received(:create) do |args|
          props = args[:body][:properties]
          expect(props[:dealname]).to eq("Listing 12345")
          expect(props[:amount]).to eq("50000.0")
          expect(props[:description]).to eq(listing.summary)
          expect(props[:closedate]).to be_a(String)
        end
      end
    end

    context "when the HubSpot API raises an error" do
      before do
        hubspot_api_error = Class.new(StandardError)
        stub_const("Hubspot::Crm::Deals::ApiError", hubspot_api_error)
        allow(api_double).to receive(:create).and_raise(
          Hubspot::Crm::Deals::ApiError.new("Quota exceeded")
        )
      end

      it "fails the context without raising" do
        expect { described_class.call(listing: listing) }.not_to raise_error
      end

      it "sets the error message" do
        result = described_class.call(listing: listing)
        expect(result).to be_failure
        expect(result.error).to include("HubSpot API error")
      end

      it "does not save a hubspot_deal_id" do
        described_class.call(listing: listing)
        expect(listing.reload.hubspot_deal_id).to be_nil
      end
    end
  end
end
