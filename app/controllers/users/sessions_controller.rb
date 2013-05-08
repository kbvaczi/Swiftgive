class Users::SessionsController < Devise::SessionsController

  include Mobylette::RespondToMobileRequests

  before_filter :require_no_authentication, :only => [ :new, :create, :new_manual ]

  
  # devise redirect after sign out
  def after_sign_out_path_for(resource)
    super
  end
  
  def sign_in_test
    sign_in_and_redirect User.first, :event => :authentication #this will throw if @user is not activated      
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