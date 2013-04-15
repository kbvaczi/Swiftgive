class Users::SessionsController < Devise::SessionsController

  include Mobylette::RespondToMobileRequests  
  
  # devise redirect after sign out
  def after_sign_out_path_for(resource)
    super
  end
  
  def sign_in_test
    sign_in_and_redirect User.first, :event => :authentication #this will throw if @user is not activated      
  end
  
end