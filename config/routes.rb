Swiftgive::Application.routes.draw do

  devise_for :users, :path => '/account', :controllers => { :registrations => 'users/registrations', 
                                                            :sessions => 'users/sessions', 
                                                            :omniauth_callbacks => "users/omniauth_callbacks" } do
    if Rails.env.development? or Rails.env.staging?                                                         
      get 'sign_in' => "users/sessions#sign_in_test" 
    end
  end 
  
  scope :module => 'users' do
    resources :payment_cards, :path => '/account/payment_cards', :only => [:create, :destroy]

    get 'account/sign_in_using_authentication/:provider'  => 'authentications#sign_in_to_existing_account', :as => :authentication_sign_in
    get 'account/register_using_authentication/:provider' => 'authentications#register_new_account', :as => :authentication_register
    get 'account/add_authentication/:provider'            => 'authentications#add_authentication_to_existing_account', :as => :authentication_add        
    get 'account/remove_authentication/:provider'         => 'authentications#remove_authentication_from_existing_account', :as => :authentication_remove

    get 'account/profile' => 'accounts#show', :as => :show_user_profile
  end 

  get 'funds/stripe_accounts/create' => 'funds/stripe_accounts#create'  
  resources :funds do
    scope :module => 'funds' do
      resources :stripe_accounts, :only => [:new, :destroy]
    end
  end
  
  # routes for testing (not for production)  
  if Rails.env.development? or Rails.env.staging?
    match 'test' => 'home#test'
    match 'test2' => 'home#test2'
  end
  
  root :to => "home#index"

  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
