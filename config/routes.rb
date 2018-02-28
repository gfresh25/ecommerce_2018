Rails.application.routes.draw do

  get 'users' => 'admin#users'

  post 'edit_users' => 'admin#edit_users'

  post 'add_to_cart' => 'cart#add_to_cart'  #Create cart with line items

  get 'view_order' => 'cart#view_order'   #read order

  get 'checkout'=>'cart#checkout'			#read checkout

  post 'edit_line_item' => 'cart#edit_line_item'

  get 'delete_line_item' => 'cart#delete_line_item'

  devise_for :users

  root 'storefront#all_items'

  get 'categorical' => 'storefront#items_by_category'

  get 'branding' => 'storefront#items_by_brand'

  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
