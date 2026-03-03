require "rails_helper"

RSpec.describe SyncListingsToHubspot do
  let!(:for_sale_listing)  { create(:listing) }
  let!(:sold_listing)      { create(:listing, :sold) }
  let!(:synced_listing)    { create(:listing, :with_hubspot_deal) }

  let(:success_outcome) { double("outcome", success?: true, failure?: false) }
  let(:failure_outcome) { double("outcome", success?: false, failure?: true, error: "API error") }

  describe "#call" do
    context "when all deals are created successfully" do
      before do
        allow(CreateHubspotDeal).to receive(:call).and_return(success_outcome)
      end

      it "only processes for-sale listings without a deal" do
        described_class.call
        expect(CreateHubspotDeal).to have_received(:call).once
        expect(CreateHubspotDeal).to have_received(:call).with(listing: for_sale_listing)
      end

      it "does not process sold listings" do
        described_class.call
        expect(CreateHubspotDeal).not_to have_received(:call).with(listing: sold_listing)
      end

      it "does not process already-synced listings" do
        described_class.call
        expect(CreateHubspotDeal).not_to have_received(:call).with(listing: synced_listing)
      end

      it "returns hubspot_results with created count" do
        result = described_class.call
        expect(result.hubspot_results).to eq({ created: 1, failed: 0 })
      end

      it "succeeds" do
        result = described_class.call
        expect(result).to be_success
      end
    end

    context "when a deal creation fails" do
      before do
        allow(CreateHubspotDeal).to receive(:call).and_return(failure_outcome)
      end

      it "does not fail the context" do
        result = described_class.call
        expect(result).to be_success
      end

      it "increments the failed count" do
        result = described_class.call
        expect(result.hubspot_results).to eq({ created: 0, failed: 1 })
      end
    end
  end
end
