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
    get :policies
  end

  # == Authentication
  resource :session, only: [ :new, :destroy ]
  resources :phone_number_verification_requests, path: "verifications", only: :create do
    member do
      post :verify
    end
  end

  # == Account
  resource :account, only: [ :new, :edit, :create, :update, :destroy ]
  resource :account_time_zone, path: "/account/time_zone", only: :update
  resource :account_app_visits, path: "/account/app_visits", only: :create

  # == Media previews
  resources :media_previews, only: [ :show ], param: :signed_id

  # == Devices
  resource :device_push_token, path: "/device/push_token", only: :update do
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
    resources :posts, only: [ :index, :new, :create ]
    resources :post_types, only: [ :new, :create ]
  end
  resources :world_keys, path: "/world/:world_id/keys", only: :index
  resources :world_key_grants, path: "/world/:world_id/key_grants", only: :new
  resources :world_invitations,
    path: "/world/:world_id/invitations",
    only: [ :new, :create ]
  resource :world_v1_posts_import,
    path: "/world/:world_id/v1_posts_import",
    only: [ :show, :create ]

  # == World Invitations
  resources :world_invitations, only: [ :show, :edit, :update, :destroy ]

  # == World Keys
  resources :world_keys, only: [ :show, :edit, :update, :destroy ] do
    collection do
      post :accept
    end
  end
  resources :world_key_world_visits,
    path: "/world_keys/:world_key_id/world_visits",
    only: :create

  # == World Cards
  # resources :world_cards, only: [ :show ] do
  #   member do
  #     get :download
  #     post :claim
  #   end
  # end

  # == World Key Grants
  resources :world_key_grants, only: :show, param: :message do
    member do
      post :accept
    end
  end

  # == Post Types
  resources :post_types, only: [ :edit, :update, :destroy ]
  resource :post_recipients_select,
    path: "/post_types/:post_type_id/post_recipients_select",
    only: :show

  # == Posts
  resources :posts, only: [ :show, :edit, :update, :destroy ] do
    member do
      post :favorite
      post :unfavorite
    end
    resources :reactions, only: [ :index, :create ]
    resources :reply_initiations, only: :create
  end
  resource :post_card, path: "posts/:post_id/card", only: :show
  resource :post_draft, only: [] do
    post :restore
  end

  # == Reactions
  resources :reactions, only: :destroy

  # == Install
  resource :installation_instructions, path: "/install", only: :show

  # == Passkit
  mount Passkit::Engine => "/passkit", as: "passkit"

  # == Devtools
  get "/fly" => redirect(Rails.configuration.fly_url, redirect: 302)
  get "/logs" => redirect(Rails.configuration.logs_url, status: 302)
  get "/metrics" => redirect(Rails.configuration.metrics_url, status: 302)
  get "/sentry" => redirect(Rails.configuration.sentry_url, status: 302)

  # == V1 Redirects
  scope controller: "v1_redirects" do
    get "/start/pwa", action: "redirect"
    get "/@:v1_world_handle", action: "redirect"
  end

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
