module HubspotConfig
  def self.access_token
    @access_token ||= ENV.fetch("HUBSPOT_ACCESS_TOKEN") {
      Rails.application.credentials.dig(:hubspot, :access_token)
    }
  end

  def self.client
    Hubspot::Client.new(access_token: access_token)
  end
end
