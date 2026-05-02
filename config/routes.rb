# typed: true
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
  resources :phone_number_verification_requests, only: [ :create ] do
    member do
      get :challenge
      post :verify
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
  resources :worlds do
    resources :posts, shallow: true
  end

  # == Devtools
  get "/fly" => redirect(
    "https://fly.io/apps/smallerworld",
    redirect: 307,
  )
  get "/logs" => redirect(
    "https://fly-metrics.net/d/fly-logs/fly-logs?orgId=256205&var-app=smallerworld",
    status: 307,
  )
  get "/metrics" => redirect(
    "https://fly-metrics.net/d/fly-app/fly-app?orgId=256205&var-app=smallerworld",
    status: 307,
  )
  get "/errors" => redirect(
    "https://smallerworld.sentry.io/issues/?project=4510862952235008",
    status: 307,
  )

  # == Admin
  namespace :admin do
    scope controller: :dashboard, as: :dashboard do
      get "/", action: :show
    end
  end
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
end
