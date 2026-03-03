require "sidekiq/web"

# API-only mode strips session middleware; add it back just for Sidekiq::Web
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore,
  key: "_empire_flippers_sidekiq_session",
  secret: Rails.application.secret_key_base

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :listings, only: [ :index ]

  mount Sidekiq::Web => "/sidekiq"
end
