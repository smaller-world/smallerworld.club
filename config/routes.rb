# typed: strict
# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get :up, to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # == Well-known
  scope controller: :well_known, path: "/.well-known" do
    get "/apple-app-site-association", action: :apple_app_site_association
  end

  # == Path configuration
  resources :path_configurations, only: :show, constraints: { id: /[\w_]+/ }

  # == Pages
  scope controller: :pages do
    root action: :landing
  end

  # == Authentication
  resource :session, only: [ :new, :destroy ]
  resources :phone_number_verification_requests, path: "verifications", only: [ :create ] do
    member do
      # get :challenge
      post :verify
    end
  end

  # == Account
  resource :account, only: [ :new, :create ]
  resource :account_time_zone, path: "/account/time_zone", only: [ :update ]

  # == Media previews
  resources :media_previews, only: [ :show ], param: :signed_id

  # == Devices
  resource :device_push_token, path: "/device/push_token", only: [ :update ] do
    post :test
  end

  # resource :apple_oauth_session, path: "/session/apple_oauth", only: :create do
  #   post :callback
  # end
  # resource :google_oauth_session, path: "/session/google_oauth", only: :create do
  #   get :callback
  # end
  # resources :passwords, param: :token

  # == Home
  get :home, to: "home#show"

  # == Worlds
  resources :worlds, except: :index do
    member do
      post :leave
    end
    resources :posts, only: [ :index, :new, :create ]
  end
  resource :world_settings, path: "/world/:world_id/settings", only: :show
  resource :world_keys, path: "/world/:world_id/keys", only: [ :show, :edit, :update ]
  resource(
    :world_v1_posts_import,
    path: "/world/:world_id/v1_posts_import",
    only: [ :show, :create ],
  )
  resources :world_cards, path: "world/:world_id/cards", only: :create
  resources :world_key_grants, path: "/world/:world_id/key_grants", only: :new

  # == World Keys
  resources :world_keys, only: [ :destroy ] do
    collection do
      post :accept
    end
  end

  # == World Cards
  resources :world_cards, only: [ :show ] do
    member do
      get :download
      post :claim
    end
  end
  resource :world_card_key_grant, path: "/world_cards/:card_id/key_grant", only: :show do
    post :accept
  end

  # == World Key Grants
  resources :world_key_grants, only: [ :show ], param: :grant do
    member do
      post :accept
    end
  end

  # == Posts
  resources :posts, only: [ :show, :edit, :update, :destroy ] do
    resources :reactions, only: [ :index, :create ]
    resources :reply_initiations, only: :create
  end
  resource :post_card, path: "posts/:post_id/card", only: :show

  # == Reactions
  resources :reactions, only: :destroy

  # == Appstore Listing
  resource :appstore_listing, path: "/appstore", only: :show

  # == Passkit
  mount Passkit::Engine => "/passkit", as: "passkit"

  # == Devtools
  get "/fly" => redirect(Rails.configuration.fly_url, redirect: 302)
  get "/logs" => redirect(Rails.configuration.logs_url, status: 302)
  get "/metrics" => redirect(Rails.configuration.metrics_url, status: 302)
  get "/sentry" => redirect(Rails.configuration.sentry_url, status: 302)

  # == UI Docs
  resources :ui_docs, path: "/ui", only: [ :index, :show ], param: :component

  # == Admin
  if Rails.env.development?
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  # == Testing
  if Rails.env.test? || defined?(Tapioca::Dsl::Pipeline)
    scope path: "/test", controller: :tests, as: :test do
      get "sign_in/:user_id", action: :sign_in, as: :sign_in
    end
  end
end
