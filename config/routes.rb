Rails.application.routes.draw do
  resources :orders, except: :new
  get "orders/:id/checkout" => "orders#checkout", as: "checkout_order"
  root "products#index"
  get "products/sales" => "products#sales"
  resources :products
  devise_for :users

  post 'line_items' => "line_items#create"
  post 'line_items/:id/add' => "line_items#add", as: "line_item_add"
  post 'line_items/:id/subtract' => "line_items#subtract", as: "line_item_subtract"
  delete 'line_items/:id' => "line_items#destroy", as: "line_item"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
