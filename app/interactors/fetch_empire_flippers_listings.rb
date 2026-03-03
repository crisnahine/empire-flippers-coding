class FetchEmpireFlippersListings
  include Interactor

  BASE_URL   = "https://api.empireflippers.com/api/v1/listings/list"
  PAGE_SIZE  = 100
  RATE_LIMIT = 1.0

  def call
    all_listings = []
    total_pages  = nil
    page         = 1

    loop do
      data        = fetch_page(page)
      total_pages ||= data["pages"].to_i

      all_listings.concat(data["listings"] || [])
      break if page >= total_pages

      page += 1
      sleep(RATE_LIMIT)
    end

    context.raw_listings = all_listings
  rescue StandardError => e
    context.fail!(error: "Failed to fetch listings: #{e.message}")
  end

  private

  def fetch_page(page)
    uri       = URI(BASE_URL)
    uri.query = URI.encode_www_form(page: page, limit: PAGE_SIZE)
    response  = Net::HTTP.get_response(uri)

    raise "HTTP #{response.code}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).fetch("data")
  end
end
