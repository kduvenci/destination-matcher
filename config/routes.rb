Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :cities, only: [:index, :show]
  get '/change_first_pick', to: 'cities#change_first_pick'

  resources :favorites, only: [:index, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :visas, only: [:show]
end
