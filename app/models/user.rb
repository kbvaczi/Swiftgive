class User < ActiveRecord::Base

  # ----- Table Setup ----- #
  
  # Include default devise modules. Others available are:
  # :token_authenticatable,  :timeoutable 
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, 
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :linkedin]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid,
                  :first_name, :last_name, :city, :state, :country, :image
  
  has_many :authentications, :class_name => 'Users::Authentication', :dependent => :destroy
  
  # ----- Member Methods ----- #
  
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end    
  end
  
  def password_required?
    super && self.authentications.nil?
  end
  
  def build_authentication(options={})
    options = {:standardized_auth_data => nil, :raw_auth_data => nil}.merge(options)    
    self.authentications.build(options[:standardized_auth_data].slice(:provider, :uid).merge(:omniauth_data => options[:raw_auth_data].to_yaml))
  end
  
  def update_authentication_raw_data(options={})
    options = {:standardized_auth_data => nil, :raw_auth_data => nil}.merge(options)    
    self.authentications.where(options[:standardized_auth_data].slice(:provider, :uid)).first.update_attribute(:omniauth_data, options[:raw_auth_data])
  end
  
  def remove_authentication(options={})
    options = {:standardized_auth_data => nil}.merge(options)
    minimum_authentications = 1
    if self.authentications.count > minimum_authentications
      self.authentications.where(options[:standardized_auth_data].slice(:provider, :uid)).first.destroy
      return true
    else
      return false
    end
  end
  # ----- Class Methods ----- #
  
  def self.create_from_omniauth(options={})
    options = {:standardized_auth_data => nil, :raw_auth_data => nil}.merge(options)    
    existing_authentication = Users::Authentication.where(options[:standardized_auth_data].slice(:provider, :uid)).first    
    unless existing_authentication.present?
      user = new(options[:standardized_auth_data].slice(*(User.new.attributes.keys.collect {|k| k.to_sym})))
      user.confirmed_at = Time.now.utc # emails are considered confirmed if imported from omniauth
      user.build_authentication(options)
      user.save
      return user
    end
    return nil
  end
  
  def self.find_from_omniauth(options={})
    options = {:standardized_auth_data => nil}.merge(options)
    existing_authentication = Users::Authentication.where(options[:standardized_auth_data].slice(:provider, :uid)).first    
    if existing_authentication.present? 
      user = existing_authentication.user
      return user
    end
    return nil
  end
  

  
end
