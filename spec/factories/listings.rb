FactoryBot.define do
  factory :listing do
    sequence(:listing_number) { |n| 10_000 + n }
    listing_price             { 50_000.00 }
    listing_status            { "For Sale" }
    summary                   { "A profitable online business." }
    hubspot_deal_id           { nil }

    trait :sold do
      listing_status { "Sold" }
    end

    trait :with_hubspot_deal do
      hubspot_deal_id { "12345678" }
    end
  end
end
