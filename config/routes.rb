Swiftgive::Application.routes.draw do

  devise_for :users, :path => '/account', :controllers => { :registrations => 'users/registrations', 
                                                            :sessions => 'users/sessions', 
                                                            :omniauth_callbacks => "users/omniauth_callbacks" } do
    get 'account/register_after_authenticated' => 'users/omniauth_callbacks#process_authentication_request', :as => :authentication_register_after_authenticated                                                              
    if Rails.env.development? or Rails.env.staging?                                                         
      get 'sign_in' => "users/sessions#sign_in_test" 
    end
  end 
  
  scope :module => 'users' do
    namespace :account do
      resources :payment_cards, :path => 'payment_cards', :only => [:create, :destroy]
      resources :bank_accounts, :path => 'bank_accounts', :only => [:create, :destroy]      
    end
    
    get 'account/sign_in_using_authentication/:provider'  => 'authentications#sign_in', :as => :authentication_sign_in
    get 'account/prompt_to_register'                      => 'authentications#prompt_to_register', :as => :authentication_prompt_to_register
    get 'account/register_using_authentication/:provider' => 'authentications#register_new_account', :as => :authentication_register
    get 'account/add_authentication/:provider'            => 'authentications#add_authentication_to_existing_account', :as => :authentication_add        
    get 'account/remove_authentication/:provider'         => 'authentications#remove_authentication_from_existing_account', :as => :authentication_remove

    get 'account/profile' => 'accounts#show', :as => :show_user_profile
    match 'account/location' => 'account/locations#update', :as => :users_location
  end 

  resources :funds do
    get 'give_code' => 'funds/give_codes#show', :on => :member
    get 'give_code_html' => 'funds/give_codes#give_code_html', :on => :member    
    get 'give_code_image' => 'funds/give_codes#give_code_image', :on => :member
    scope :module => 'funds' do
      resources :bank_accounts, :only => [:new, :destroy]
    end
  end
  
  resources :payments, :only => [:new, :create]
  
  # routes for testing (not for production)  
  if Rails.env.development? or Rails.env.staging?
    match 'test' => 'home#test'
    match 'test2' => 'home#test2'
  end
  
  # dynamic robots.txt per environment
  get '/robots.txt' => 'home#robots'
  
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
