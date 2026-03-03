class SyncListings
  include Interactor::Organizer

  organize FetchEmpireFlippersListings, UpsertListings, SyncListingsToHubspot
end
