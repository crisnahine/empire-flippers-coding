# Empire Flippers + HubSpot Integration

A Rails 7.2 API app that syncs listings from the Empire Flippers public API into PostgreSQL and creates HubSpot deals for all active "For Sale" listings.

## What it does

- Fetches all listings daily from the Empire Flippers API
- Stores them in a PostgreSQL database
- Creates a HubSpot Deal for every "For Sale" listing (no duplicates)
- Exposes a paginated REST endpoint to browse listings

## Tech Stack

- **Ruby** 3.1.2 / **Rails** 7.2
- **PostgreSQL** — listings storage
- **Sidekiq** + **sidekiq-scheduler** — daily background sync at 06:00 UTC
- **HubSpot API Client** — deal creation via Private App token
- **Interactor** — service layer with organizer pattern
- **Pagy** + **Jbuilder** — paginated JSON API

## Requirements

- Ruby 3.1.2
- PostgreSQL
- Redis

## Setup

```bash
# Install dependencies
bundle install

# Set up the database
rails db:create db:migrate

# Add your HubSpot Private App token to credentials
EDITOR=nano rails credentials:edit
```

In the credentials file add:
```yaml
hubspot:
  access_token: pat-na1-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

To get a HubSpot Private App token:
1. Go to HubSpot → Settings → Integrations → Private Apps
2. Create a new app with `crm.objects.deals.read` and `crm.objects.deals.write` scopes
3. Copy the generated token

## Running the app

```bash
# Start the Rails server
rails server

# Start Sidekiq (in a separate terminal)
bundle exec sidekiq -C config/sidekiq.yml
```

## API Endpoints

### `GET /listings`

Returns a paginated list of all listings.

**Query params:**
- `page` — page number (default: 1)
- `limit` — items per page (default: 20, max: 100)

**Example:**
```bash
curl "http://localhost:3000/listings?page=1&limit=5"
```

**Response:**
```json
{
  "data": [
    {
      "listing_number": 92280,
      "listing_price": "275137.0",
      "listing_status": "For Sale",
      "summary": "..."
    }
  ],
  "pagination": {
    "count": 2836,
    "page": 1,
    "next": 2,
    "prev": null,
    "last": 142
  }
}
```

### `GET /up`

Health check — returns 200 if the app is running.

### `GET /sidekiq`

Sidekiq Web UI — monitor background jobs and the daily sync schedule.

## How the sync works

The daily sync runs at 06:00 UTC via `SyncListingsJob` and goes through three steps:

1. **FetchEmpireFlippersListings** — fetches all pages from the Empire Flippers API
2. **UpsertListings** — inserts/updates listings in PostgreSQL (never overwrites existing HubSpot deal IDs)
3. **SyncListingsToHubspot** — creates a HubSpot Deal for every "For Sale" listing that doesn't have one yet

To trigger it manually:
```ruby
# In rails console
SyncListingsJob.perform_now
```

## HubSpot Deal Properties

| Property | Value |
|---|---|
| Deal Name | `Listing #{listing_number}` |
| Amount | `listing_price` |
| Close Date | 30 days from sync time |
| Description | `summary` |

## Tests

```bash
bundle exec rspec
```

47 examples, covering models, request endpoints, all interactors, and the job.
