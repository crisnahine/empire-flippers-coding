class CreateListings < ActiveRecord::Migration[7.2]
  def change
    create_table :listings do |t|
      t.integer  :listing_number, null: false
      t.decimal  :listing_price,  precision: 15, scale: 2
      t.string   :listing_status, null: false
      t.text     :summary
      t.string   :hubspot_deal_id

      t.timestamps
    end

    add_index :listings, :listing_number, unique: true
    add_index :listings, :hubspot_deal_id
    add_index :listings, :listing_status
  end
end
