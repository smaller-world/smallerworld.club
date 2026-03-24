# typed: true
# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get :up, to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  scope controller: :pages do
    root action: :landing
  end

  # == Authentication ==
  resource :session
  resources :passwords, param: :token

  # == Home ==
  scope path: "/home", controller: :home do
    get "/", action: :show
  end

  # == WASenderAPI ==
  scope path: "/wasenderapi", controller: :wa_sender_api do
    post :webhook
  end

  # == Whatsapp Groups ==
  resources :whatsapp_groups, path: "/groups", only: [] do
    member do
      get :message_history
    end
    resources :whatsapp_messages, path: "/messages", only: :index
  end

  # == Events ==
  resources :events, only: [] do
    collection do
      get :luma_redirect
    end
  end

  # == Devtools ==
  get "/fly" => redirect(
    "https://fly.io/apps/happytown",
    redirect: 307,
  )
  get "/logs" => redirect(
    "https://fly-metrics.net/d/fly-logs/fly-logs?orgId=256205&var-app=happytown",
    status: 307,
  )
  get "/metrics" => redirect(
    "https://fly-metrics.net/d/fly-app/fly-app?orgId=256205&var-app=happytown",
    status: 307,
  )
  get "/errors" => redirect(
    "https://happytown.sentry.io/issues/?project=4510862952235008",
    status: 307,
  )

  # == Admin ==

  namespace :admin do
    scope controller: :dashboard, as: :dashboard do
      get "/", action: :show
    end
    resources :webhook_messages, path: "webhook_logs", only: :index
  end
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
end
