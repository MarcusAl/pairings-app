Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [:index, :show, :destroy]
  resource  :password, only: [:edit, :update]
  namespace :identity do
    resource :email,              only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset,     only: [:new, :edit, :create, :update]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # Defines the root path route ("/")
  # root "posts#index"
  draw(:sidekiq)
end
