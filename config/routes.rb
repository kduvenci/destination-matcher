Rails.application.routes.draw do
  devise_for :users
  root to: 'cities#index'
  resources :cities, only: [:index, :show] do
    resources :favorites, only: [:create]
  end

  resources :favorites, only: [:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
