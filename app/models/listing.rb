class Listing < ApplicationRecord
  FOR_SALE_STATUS = "For Sale"

  validates :listing_number, presence: true, uniqueness: true
  validates :listing_status, presence: true

  scope :for_sale,             -> { where(listing_status: FOR_SALE_STATUS) }
  scope :without_hubspot_deal, -> { where(hubspot_deal_id: nil) }
end
