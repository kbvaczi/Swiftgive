Swiftgive::Application.routes.draw do

  devise_for :users, :path => '/account', :controllers => { :registrations => 'users/registrations', 
                                                            :sessions => 'users/sessions', 
                                                            :omniauth_callbacks => "users/omniauth_callbacks",
                                                            :passwords => 'users/passwords' } do
    get 'account/register_after_authenticated' => 'users/omniauth_callbacks#process_authentication_request', :as => :authentication_register_after_authenticated                                                              
    get 'account/manual_sign_in' => 'users/sessions#new_manual'
  end
  
  scope :module => 'users' do
    get 'account/sign_in_using_authentication/:provider'  => 'authentications#sign_in', :as => :authentication_sign_in
    get 'account/prompt_to_register'                      => 'authentications#prompt_to_register', :as => :authentication_prompt_to_register
    get 'account/register_using_authentication/:provider' => 'authentications#register_new_account', :as => :authentication_register
    get 'account/add_authentication/:provider'            => 'authentications#add_authentication_to_existing_account', :as => :authentication_add        
    get 'account/remove_authentication/:provider'         => 'authentications#remove_authentication_from_existing_account', :as => :authentication_remove
  end

  get 'profile' => 'accounts#show', :as => :show_user_profile
  put 'profile/update' => 'accounts#update', :as => :update_user_profile
  
  resources :accounts, :only => [:show]

  namespace :accounts do
    resources :payment_cards, :path => 'payment_cards', :only => [:create, :destroy]    
    get 'location' => 'locations#edit', :as => :location
    put 'location' => 'locations#update', :as => :location
  end
  
  resources :funds do
    get 'promote' => 'funds#promote', :on => :member
    get 'give_code' => 'funds#give_code', :on => :member
    get 'manage/(:section)' => 'funds#manage', :on => :member, :as => 'manage'
    put 'toggle_active_status', :on => :member, :as => 'toggle_active_status'    
    get 'give_code_html/(:product)' => 'funds/give_codes#give_code_html', :on => :member, :as => :give_code_html
    get 'give_code_image' => 'funds/give_codes#give_code_image', :on => :member, :defaults => { :format => 'pdf' }
  end
  
  get 'payments/new/:fund_uid' => 'payments#new', :as => 'new_payment'
  get 'payments/guest_splash'  => 'payments#guest_splash', :as => 'guest_splash'
  resources :payments, :only => [:create, :show]
  
  # routes for testing (not for production)  
  if Rails.env.development? or Rails.env.staging?
    match 'test' => 'home#test'

    # sidekiq monitoring server... we will have dedicated server for production
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
  
  # dynamic robots.txt per environment, we don't want bots crawling on development or staging sites
  get '/robots.txt' => 'home#robots'
  
  # simple contact form
  match 'contact'             => 'contact#index'
  match 'contact_create'      => 'contact#create'
  
  match 'about'               => 'home#about'
  match 'terms'               => 'home#terms'
  match 'privacy'             => 'home#privacy'

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
