class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  include Mobylette::RespondToMobileRequests  
  include Devise::Controllers::Rememberable # allows us to use remember_me helper to persist sessions
  
  def facebook
    @raw_auth_data   = request.env["omniauth.auth"]
    city_name    = @raw_auth_data.info.location.partition(', ')[0].titleize rescue nil
    state_name   = @raw_auth_data.info.location.partition(', ')[2].titleize rescue nil

    # import state/country info if it's in the USA
    state_code   = Carmen::Country.coded('US').subregions.named(state_name, {:fuzzy => false, :case => false}).code rescue nil
    country_code = state_code.present? ? 'US' : nil

    @standardized_auth_data = { :provider => @raw_auth_data.provider,
                                :provider_name => 'Facebook', 
                                :uid => @raw_auth_data.uid,
                                :email => @raw_auth_data.info.email, 
                                :first_name => (@raw_auth_data.info.first_name rescue nil), 
                                :last_name => (@raw_auth_data.info.last_name rescue nil),
                                :city => city_name, 
                                :state => state_code,
                                :country => country_code,
                                :image => (@raw_auth_data.info.image rescue nil) }                               

    store_auth_data(@standardized_auth_data)
    process_authentication_request
  end
  
  def google_oauth2
    @raw_auth_data = request.env["omniauth.auth"]
    @standardized_auth_data = { :provider => @raw_auth_data.provider,
                                :provider_name => 'Google',
                                :uid => @raw_auth_data.uid,
                                :email => @raw_auth_data.info.email, 
                                :first_name => (@raw_auth_data.info.first_name rescue nil), 
                                :last_name => (@raw_auth_data.info.last_name rescue nil),
                                :image => (@raw_auth_data.info.image rescue nil) }
 
    store_auth_data(@standardized_auth_data)                                
    process_authentication_request
	end
	
	def linkedin
    @raw_auth_data = request.env["omniauth.auth"]
    city_name  = @raw_auth_data.info.location.partition(', ')[0].titleize rescue nil
    state_name = @raw_auth_data.info.location.partition(', ')[2].partition(/ area/i)[0].titleize rescue nil
    country_code = Carmen::Country.coded((@raw_auth_data.extra.raw_info.location.country.code.upcase rescue nil)).code rescue nil        
    state_code   = Carmen::Country.coded(country_code).subregions.named(state_name, {:fuzzy => false, :case => false}).code rescue nil
    @standardized_auth_data = { :provider => @raw_auth_data.provider,
                                :provider_name => 'LinkedIn',
                                :uid => @raw_auth_data.uid,
                                :email => @raw_auth_data.info.email, 
                                :first_name => (@raw_auth_data.info.first_name rescue nil), 
                                :last_name => (@raw_auth_data.info.last_name rescue nil),
                                :country => country_code,                                
                                :city => city_name, 
                                :state => state_code,
                                :image => (@raw_auth_data.info.image rescue nil) }

    store_auth_data(@standardized_auth_data)                                
    process_authentication_request
	end
	
	def process_authentication_request
    if session['devise.authentication_reason'] == 'register'
      register_new_account
    elsif user_signed_in? and session['devise.authentication_reason'] == 'add_authentication'
      add_authentication_to_existing_account
    elsif user_signed_in? and session['devise.authentication_reason'] == 'remove_authentication'
      remove_authentication_from_existing_account      
    else
      sign_in_existing_user
    end
  end
	
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
  protected
  
  def store_auth_data(standardized_data_hash=nil)
    session['devise.standardized_omniauth_data'] = standardized_data_hash
    session['devise.raw_omniauth_data'] = request.env['omniauth.auth'] if request.env['omniauth.auth'].present?
  end
  
  def standardized_auth_data
    @standardized_auth_data ||= session['devise.standardized_omniauth_data']
  end
  
  def raw_auth_data
    @raw_auth_data ||= session['devise.raw_omniauth_data']
  end

  def register_new_account
    user = User.create_from_omniauth(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data)
    if user.present? and user.persisted?
      set_flash_message(:notice, :success, :kind => standardized_auth_data[:provider_name]) if is_navigational_format?
      remember_me(user)
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated      
    #TODO - do we want to allow manual authentication?
    elsif user.present? # there were errors creating the user
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_path
    else # user is nil, meaning the authentication already exists
      flash[:error] = "This #{standardized_auth_data[:provider_name]} account is already linked with another user profile..."
      redirect_to back_path
    end
  end
  
  def sign_in_existing_user
    user = User.find_from_omniauth(:standardized_auth_data => standardized_auth_data)
    if user.present? and user.persisted?
      user.update_authentication_raw_data(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data)
      set_flash_message(:notice, :success, :kind => standardized_auth_data[:provider_name]) if is_navigational_format?      
      remember_me(user)      
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated
    else
      redirect_to authentication_prompt_to_register_path
    end
  end
  
  def add_authentication_to_existing_account
    existing_user_associated_with_omniauth = User.find_from_omniauth(:standardized_auth_data => standardized_auth_data)
    if not existing_user_associated_with_omniauth.present?
      if current_user.build_authentication(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data).save
        redirect_to back_path, :notice => "Successfully linked #{standardized_auth_data[:provider_name]} account to your user profile..."
      else
        flash[:error] = "Unable to link #{standardized_auth_data[:provider_name]} account to your user profile..."
        redirect_to back_path
      end
    elsif existing_user_associated_with_omniauth.id == current_user.id
      redirect_to back_path, :notice => "This #{standardized_auth_data[:provider_name]} account is already linked to your user profile..."
    else
      flash[:error] = "This #{standardized_auth_data[:provider_name]} account is already linked to another user profile..."
      redirect_to root_path      
    end
  end
  
  def remove_authentication_from_existing_account
    existing_user_associated_with_omniauth = User.find_from_omniauth(:standardized_auth_data => standardized_auth_data)
    if existing_user_associated_with_omniauth.present? and existing_user_associated_with_omniauth.id == current_user.id
      if current_user.remove_authentication(:standardized_auth_data => standardized_auth_data)
        redirect_to back_path, :notice => "Successfully removed #{standardized_auth_data[:provider_name]} account from your user profile..."        
      else
        flash[:error] = "Unable to remove #{standardized_auth_data[:provider_name]} account from your user profile..."
        redirect_to back_path
      end
    else
      flash[:error] = "This #{standardized_auth_data[:provider_name]} account is not linked to your user profile..."
      redirect_to back_path
    end    
  end
  
end