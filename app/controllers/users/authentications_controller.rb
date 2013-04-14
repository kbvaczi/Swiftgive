class Users::AuthenticationsController < ApplicationController

  include Mobylette::RespondToMobileRequests  
  
  before_filter :authenticate_user!, :only => [:add_authentication_to_existing_account, :remove_authentication_from_existing_account]
  before_filter :require_no_authentication, :only => [:sign_in_to_existing_account, :register_new_account]
  
  def sign_in_to_existing_account
    session['devise.authentication_reason'] = 'sign_in'
    redirect_to user_omniauth_authorize_path(params[:provider])
  end
  
  def register_new_account
    session['devise.authentication_reason'] = 'register'
    redirect_to user_omniauth_authorize_path(params[:provider])
  end
  
  def add_authentication_to_existing_account
    session['devise.authentication_reason'] = 'add_authentication'
    redirect_to user_omniauth_authorize_path(params[:provider])
  end
  
  def remove_authentication_from_existing_account
    session['devise.authentication_reason'] = 'remove_authentication'
    redirect_to user_omniauth_authorize_path(params[:provider])
  end  
  
  protected
  
  def require_no_authentication
    if user_signed_in?
      flash[:error] = 'You are already signed in.'
      redirect_to back_path
    end
  end

end
