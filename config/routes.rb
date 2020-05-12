Rails.application.routes.draw do
  resources :orders
  get "orders/:id/purchase" => "orders#purchase", as: "purchase_order"
  root "products#index"
  resources :products
  devise_for :users

  post 'line_items' => "line_items#create"
  post 'line_items/:id/add' => "line_items#add", as: "line_item_add"
  post 'line_items/:id/subtract' => "line_items#subtract", as: "line_item_subtract"
  delete 'line_items/:id' => "line_items#destroy", as: "line_item"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
