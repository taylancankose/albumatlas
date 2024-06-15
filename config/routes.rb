Rails.application.routes.draw do
  root 'users#index'
  get 'search', to: 'users#search'
  # resources :users, only: [:index, :show, :edit, :update, :new]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :users do
    resources :albums
  end
  resources :albums, only: [:show]
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "users#index"
 
end
