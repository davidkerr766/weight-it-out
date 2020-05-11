Rails.application.routes.draw do
  resources :orders
  root "products#index"
  resources :products
  devise_for :users

  post 'line_items' => "line_items#create"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
