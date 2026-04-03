namespace :web do
  root 'dashboard#index'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'signup', to: 'registrations#new'
  post 'signup', to: 'registrations#create'
  resources :items
  resources :pairings, only: %i[index show new create destroy]
  get 'explore/items', to: 'explore#items', as: :explore_items
  get 'explore/pairings', to: 'explore#pairings', as: :explore_pairings
end
