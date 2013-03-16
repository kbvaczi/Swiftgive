class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  include Devise::Controllers::Rememberable # allows us to use remember_me helper to persist sessions
  
  def facebook
    @auth_hash   = request.env["omniauth.auth"]
    city_name    = @auth_hash.info.location.partition(', ')[0] rescue nil
    state_name   = @auth_hash.info.location.partition(', ')[2] rescue nil

    # import state/country info if it's in the USA
    state_code   = Carmen::Country.coded('US').subregions.named(state_name, {:fuzzy => false, :case => false}).code rescue nil
    country_code = state_code.present? ? 'US' : nil

    @standardized_auth_data = { :provider => 'Facebook', 
                                :uid => @auth_hash.uid,
                                :email => @auth_hash.info.email, 
                                :first_name => (@auth_hash.info.first_name rescue nil), 
                                :last_name => (@auth_hash.info.last_name rescue nil),
                                :city => city_name, 
                                :state => state_code,
                                :country => country_code,
                                :image => (@auth_hash.info.image rescue nil) }                               
    common
  end
  
  def google_oauth2
    @auth_hash = request.env["omniauth.auth"]
    @standardized_auth_data = { :provider => 'Google', 
                                :uid => @auth_hash.uid,
                                :email => @auth_hash.info.email, 
                                :first_name => (@auth_hash.info.first_name rescue nil), 
                                :last_name => (@auth_hash.info.last_name rescue nil),
                                :image => (@auth_hash.info.image rescue nil) }
    common
	end
	
	def linkedin
    @auth_hash = request.env["omniauth.auth"]
    city_name  = @auth_hash.info.location.partition(', ')[0] rescue nil
    state_name = @auth_hash.info.location.partition(', ')[2].partition(/ area/i)[0] rescue nil
    country_code = Carmen::Country.coded((@auth_hash.extra.raw_info.location.country.code rescue nil)).code rescue nil
    state_code   = Carmen::Country.coded(country_code).subregions.named(state_name, {:fuzzy => false, :case => false}).code rescue nil
    @standardized_auth_data = { :provider => 'LinkedIn', 
                                :uid => @auth_hash.uid,
                                :email => @auth_hash.info.email, 
                                :first_name => (@auth_hash.info.first_name rescue nil), 
                                :last_name => (@auth_hash.info.last_name rescue nil),
                                :country => country_code,                                
                                :city => city_name, 
                                :state => state_code,
                                :image => (@auth_hash.info.image rescue nil) }
    common
	end
	
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
  protected
  
  def common
    if session['devise.authentication_reason'] == 'register'
      register_new_account
    elsif user_signed_in? and session['devise.authentication_reason'] == 'add_authentication'
      add_authentication_to_existing_account
    elsif user_signed_in? and session['devise.authentication_reason'] == 'remove_authentication'
      remove_authentication_from_existing_account      
    else
      sign_into_existing_account
    end
  end
  
  def register_new_account
    user = User.create_from_omniauth(:standardized_auth_data => @standardized_auth_data, :raw_auth_data => @auth_hash)
    if user.present? and user.persisted?
      set_flash_message(:notice, :success, :kind => @standardized_auth_data[:provider]) if is_navigational_format?
      remember_me(user)
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated      
    elsif user.present? # there were errors creating the user
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    else # user is nil, meaning the authentication already exists
      flash[:error] = "This #{@standardized_auth_data[:provider]} account is already linked with another user profile..."
      redirect_to back_path
    end
  end
  
  def sign_into_existing_account
    user = User.find_from_omniauth(:standardized_auth_data => @standardized_auth_data)
    if user.present? and user.persisted?
      user.update_authentication_raw_data(:standardized_auth_data => @standardized_auth_data, :raw_auth_data => @auth_hash)
      set_flash_message(:notice, :success, :kind => @standardized_auth_data[:provider]) if is_navigational_format?      
      remember_me(user)      
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated
    else
      flash[:error] = "Unable to find user profile linked to this #{@standardized_auth_data[:provider]} account..."
      redirect_to root_path
    end
  end
  
  def add_authentication_to_existing_account
    existing_user_associated_with_omniauth = User.find_from_omniauth(:standardized_auth_data => @standardized_auth_data)
    if not existing_user_associated_with_omniauth.present?
      if current_user.build_authentication(:standardized_auth_data => @standardized_auth_data, :raw_auth_data => @auth_hash).save
        redirect_to back_path, :notice => "Successfully linked #{@standardized_auth_data[:provider]} account to your user profile..."
      else
        flash[:error] = "Unable to link #{@standardized_auth_data[:provider]} account to your user profile..."
        redirect_to back_path
      end
    elsif existing_user_associated_with_omniauth.id == current_user.id
      redirect_to back_path, :notice => "This #{@standardized_auth_data[:provider]} account is already linked to your user profile..."
    else
      flash[:error] = "This #{@standardized_auth_data[:provider]} account is already linked to another user profile..."
      redirect_to root_path      
    end
  end
  
  def remove_authentication_from_existing_account
    existing_user_associated_with_omniauth = User.find_from_omniauth(:standardized_auth_data => @standardized_auth_data)
    if existing_user_associated_with_omniauth.present? and existing_user_associated_with_omniauth.id == current_user.id
      if current_user.remove_authentication(:standardized_auth_data => @standardized_auth_data)
        redirect_to back_path, :notice => "Successfully removed #{@standardized_auth_data[:provider]} account from your user profile..."        
      else
        flash[:error] = "Unable to remove #{@standardized_auth_data[:provider]} account from your user profile..."
        redirect_to back_path
      end
    else
      flash[:error] = "This #{@standardized_auth_data[:provider]} account is not linked to your user profile..."
      redirect_to back_path
    end    
  end
  
end