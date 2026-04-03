Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  post 'sign_in', to: 'sessions#create'
  delete 'sign_out', to: 'sessions#destroy'
  post 'sign_up', to: 'registrations#create'

  resources :sessions, only: %i[index show destroy]

  resource  :password, only: %i[edit update]

  resources :items, only: %i[index show create update destroy]

  resources :pairings, only: %i[index show create update destroy]

  namespace :identity do
    resource :email,              only: %i[edit update]
    resource :email_verification, only: %i[show create]
    resource :password_reset,     only: %i[new edit create update]
  end

  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'

  get 'up' => 'rails/health#show', as: :rails_health_check

  draw(:web)
  draw(:sidekiq)
end
