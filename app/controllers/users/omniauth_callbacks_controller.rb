class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  include Mobylette::RespondToMobileRequests  
  include Devise::Controllers::Rememberable # allows us to use remember_me helper to persist sessions
  
  # TODO: enable banned user functionality
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

  def facebook
    @raw_auth_data   = request.env["omniauth.auth"]
    city_name    = @raw_auth_data.info.location.partition(', ')[0].titleize rescue nil
    state_name   = @raw_auth_data.info.location.partition(', ')[2].titleize rescue nil

    # import state/country info if it's in the USA
    state_code   = Carmen::Country.coded('US').subregions.named(state_name, {:fuzzy => false, :case => false}).code rescue nil

    @standardized_auth_data = { :provider => @raw_auth_data.provider,
                                :provider_name => 'Facebook', 
                                :uid => @raw_auth_data.uid,
                                :email => @raw_auth_data.info.email,
                                :account_attributes => { 
                                  :first_name => (@raw_auth_data.info.first_name rescue nil), 
                                  :last_name => (@raw_auth_data.info.last_name rescue nil),
                                  :city => city_name, 
                                  :state => state_code,
                                  :avatar => (@raw_auth_data.info.image rescue nil) 
                                } 
                              }

    store_auth_data(@standardized_auth_data)
    process_authentication_request
  end
  
  def google_oauth2
    @raw_auth_data = request.env["omniauth.auth"]
    @standardized_auth_data = { :provider => @raw_auth_data.provider,
                                :provider_name => 'Google',
                                :uid => @raw_auth_data.uid,
                                :email => @raw_auth_data.info.email,
                                :account_attributes => { 
                                  :first_name => (@raw_auth_data.info.first_name rescue nil), 
                                  :last_name => (@raw_auth_data.info.last_name rescue nil),
                                  :avatar => (@raw_auth_data.info.image rescue nil) 
                                }
                              }
 
    store_auth_data(@standardized_auth_data)                                
    process_authentication_request
	end
	
	def linkedin
    @raw_auth_data = request.env["omniauth.auth"]
    city_name  = @raw_auth_data.info.location.partition(', ')[0].titleize rescue nil
    state_name = @raw_auth_data.info.location.partition(', ')[2].partition(/ area/i)[0].titleize rescue nil
    # import state/country info if it's in the USA
    state_code   = Carmen::Country.coded('US').subregions.named(state_name, {:fuzzy => false, :case => false}).code rescue nil
    @standardized_auth_data = { :provider => @raw_auth_data.provider,
                                :provider_name => 'LinkedIn',
                                :uid => @raw_auth_data.uid,
                                :email => @raw_auth_data.info.email, 
                                :account_attributes => { 
                                  :first_name => (@raw_auth_data.info.first_name rescue nil), 
                                  :last_name => (@raw_auth_data.info.last_name rescue nil),
                                  :city => city_name, 
                                  :state => state_code,
                                  :avatar => (@raw_auth_data.info.image rescue nil) 
                                }
                              }

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
    request.session['devise.standardized_omniauth_data'] = standardized_data_hash
    request.session['devise.raw_omniauth_data'] = env["omniauth.auth"].except("extra") if request.env['omniauth.auth'].present?
  end
  
  def standardized_auth_data
    @standardized_auth_data ||= request.session['devise.standardized_omniauth_data']
  end
  
  def raw_auth_data
    @raw_auth_data ||= request.session['devise.raw_omniauth_data']
  end

  def register_new_account
    user = User.create_from_omniauth(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data)
    if user.present? and user.persisted?
      set_flash_message(:notice, :success, :kind => standardized_auth_data[:provider_name]) if is_navigational_format?
      remember_me(user)
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated      
    elsif User.where("email LIKE ?", standardized_auth_data[:email]).present? # user has authenticated using the same email with a different service, use like for case insensitive
      add_authentication_to_existing_account
    else # some other problem
      flash[:error] = "There was a problem authenticating with this #{standardized_auth_data[:provider_name]} account..."      
      redirect_to back_path
    end
  end
  
  def sign_in_existing_user
    user = User.find_from_omniauth(:standardized_auth_data => standardized_auth_data)
    if user.present? and user.persisted?
      user.update_authentication_raw_data(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data)
      set_flash_message(:notice, :success, :kind => standardized_auth_data[:provider_name]) if is_navigational_format?
      remember_me(user)
      user.update_attribute(:confirmed_at, Time.now) unless user.confirmed_at.present? # This line is needed in case someone has created an account using email, but not confirmed their address, then try to subsequently login through omniauth
      sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated
    else
      register_new_account
    end
  end
  
  def add_authentication_to_existing_account
    existing_user_associated_with_omniauth = User.find_from_omniauth(:standardized_auth_data => standardized_auth_data)
    if not existing_user_associated_with_omniauth.present?
      if user_signed_in? and current_user.build_authentication(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data).save
        redirect_to back_path, :notice => "Successfully linked #{standardized_auth_data[:provider_name]} account to your user profile..."
      elsif User.where("email LIKE ?", standardized_auth_data[:email]).first.build_authentication(:standardized_auth_data => standardized_auth_data, :raw_auth_data => raw_auth_data).save
        sign_in_existing_user
      else
        flash[:error] = "Unable to link #{standardized_auth_data[:provider_name]} account to your user profile..."
        redirect_to back_path
      end
    elsif user_signed_in? and existing_user_associated_with_omniauth.id == current_user.id
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