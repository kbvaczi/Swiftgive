class Users::SessionsController < Devise::SessionsController

  include Mobylette::RespondToMobileRequests

  before_filter :require_no_authentication, :only => [ :new, :create, :new_manual ]

  
  # devise redirect after sign out
  def after_sign_out_path_for(resource)
    super
  end
  
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
        back_path
      end
    else
      super
    end
  end

  def new
    if params[:user].present?
      redirect_to account_manual_sign_in_path(:user => params[:user])
    else
      super
    end
  end

  def new_manual
    @user = User.new(params[:user])
    flash[:error] = 'Invalid email and/or password' if params[:user].present?
  end
  
end