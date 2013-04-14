class Users::SessionsController < Devise::SessionsController

  include Mobylette::RespondToMobileRequests  
  
  # do this after a user signs in
  #TODO: implement banned funcationality for users
  def after_sign_in_path_for(resource) 
    if resource.is_a?(User)
      if false # resource.banned?
        sign_out resource
        flash[:error]  = "This account has been suspended..."
        flash[:notice] = nil # erase any notice so that error can be displayed
        root_path
      else
        flash[:notice] = "Welcome back!"
        back_path
      end
    else
      super
    end
  end
  
  # devise redirect after sign out
  def after_sign_out_path_for(resource)
    super
  end
  
  def sign_in_test
    sign_in_and_redirect User.first, :event => :authentication #this will throw if @user is not activated      
  end
  
end