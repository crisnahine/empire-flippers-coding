json.data(@listings) do |listing|
  json.listing_number listing.listing_number
  json.listing_price  listing.listing_price
  json.listing_status listing.listing_status
  json.summary        listing.summary
end

json.pagination do
  json.count @pagy.count
  json.page  @pagy.page
  json.next  @pagy.next
  json.prev  @pagy.prev
  json.last  @pagy.last
end
