# typed: strict
# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get :up, to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

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
  resource :account, only: [ :new, :create ] do
    scope module: :accounts  do
      resource :time_zone, only: [ :update ]
    end
  end

  # == Media previews
  resources :media_previews, only: [ :show ], param: :signed_id

  # == Devices
  resource :device, only: [] do
    scope module: :devices do
      resource :push_token, only: [ :update ] do
        post :test
      end
      resource :world_cards, only: [ :update ]
    end
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
    resources :posts, only: [ :index, :new, :create ]
    resources :world_keys,
      path: "/keys",
      only: [ :index ]
    resources :world_cards,
      path: "/cards",
      only: [ :create ]
    resources :world_key_grants,
      path: "/invitations",
      as: :key_grants,
      only: :new
  end

  # == World Keys
  resources :world_keys, only: [ :destroy ] do
    collection do
      post :accept
    end
  end

  # == World Cards
  resources :world_cards, only: [ :show ] do
    collection do
      get :unlinked
    end
  end

  # == World Key Grants
  resources :world_key_grants, only: [ :show ], param: :grant, path: "/world_invitations"

  # == Posts
  resources :posts, only: [ :show, :edit, :update, :destroy ] do
    resources :reactions, only: [ :index, :create ]
    resources :reply_initiations, only: :create
  end

  # == Reactions
  resources :reactions, only: :destroy

  # == Testflight
  get "/testflight",
    to: redirect(Rails.configuration.testflight_url, status: 307),
    as: :testflight

  # == Passkit
  mount Passkit::Engine => "/passkit", as: "passkit"

  # == Devtools
  get "/fly" => redirect(Rails.configuration.fly_url, redirect: 307)
  get "/logs" => redirect(Rails.configuration.logs_url, status: 307)
  get "/metrics" => redirect(Rails.configuration.metrics_url, status: 307)
  get "/errors" => redirect(Rails.configuration.sentry_url, status: 307)

  # == UI Docs
  resources :ui_docs, path: "/ui", only: [ :index, :show ], param: :component

  # == Admin
  if Rails.env.development?
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
