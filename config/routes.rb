Rails.application.routes.draw do
  root 'users#index'
  get 'search', to: 'users#search'
  resources :users do
    resources :albums
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
