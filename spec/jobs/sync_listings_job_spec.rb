require "rails_helper"

RSpec.describe SyncListingsJob, type: :job do
  let(:raw_listings) do
    [
      { "listing_number" => 11111, "listing_price" => 75_000.0, "listing_status" => "For Sale", "summary" => "Listing one" },
      { "listing_number" => 22222, "listing_price" => 120_000.0, "listing_status" => "Sold", "summary" => "Listing two" }
    ]
  end

  let(:success_result) do
    double("result",
      success?: true,
      failure?: false,
      upserted_count: 2,
      hubspot_results: { created: 1, failed: 0 })
  end

  let(:failure_result) do
    double("result", success?: false, failure?: true, error: "API error")
  end

  describe "#perform" do
    context "when SyncListings succeeds" do
      before do
        allow(SyncListings).to receive(:call).and_return(success_result)
      end

      it "calls SyncListings" do
        described_class.perform_now
        expect(SyncListings).to have_received(:call)
      end

      it "does not raise an error" do
        expect { described_class.perform_now }.not_to raise_error
      end
    end

    context "when SyncListings fails" do
      before do
        allow(SyncListings).to receive(:call).and_return(failure_result)
      end

      it "raises an error so Sidekiq retries the job" do
        expect { described_class.perform_now }.to raise_error("API error")
      end
    end
  end
end
