class User < ActiveRecord::Base

  # ----- Table Setup ----- #
  
  # Include default devise modules. Others available are:
  # :token_authenticatable,  :timeoutable 
  
  devise  :database_authenticatable, :async, # uses devise async gem to send emails using backgroudn worker process
          :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, # standard Devise stuff
          :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :linkedin] # allows users to login through omniauth authentications
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :current_password, :remember_me, :account_attributes
  
  has_one     :account, :dependent => :destroy
  has_many    :funds,             :class_name => 'Fund',                  :through => :fund_memberships
  has_many    :fund_memberships,  :class_name => 'Funds::Membership'
  has_many    :payments,          :class_name => 'Payment',               :foreign_key => :sender_id
  has_many    :authentications,   :class_name => 'Users::Authentication', :dependent => :destroy
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :account

  # ----- Validations ----- #
  
  validates_presence_of   :email
  validates_uniqueness_of :email
  validates_length_of :password, :minimum => 8

  # ----- Callbacks ----- #

  after_initialize  :build_account_when_creating_new_user, :on => :create

  # ----- Member Methods ----- #
  
  # used to determine if password is required to update account info.  Omniauth authenticated users will have a randomly generated password.
  def password_required?
    super && self.is_password_set
  end
  
  def build_authentication(options={})
    options = {:standardized_auth_data => nil, :raw_auth_data => nil}.merge(options)    
    self.authentications.build(options[:standardized_auth_data].slice(:provider, :provider_name, :uid).merge(:omniauth_data => options[:raw_auth_data].to_yaml))
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

  def self.create_from_omniauth(options={})
    options = {:standardized_auth_data => nil, :raw_auth_data => nil}.merge(options)    
    existing_authentication = Users::Authentication.where(options[:standardized_auth_data].slice(:provider, :uid)).first    
    unless existing_authentication.present?
      new_user = new(options[:standardized_auth_data].slice(:email, :account_attributes))
      new_user.confirmed_at = Time.now.utc # emails are considered confirmed if imported from omniauth
      new_user.build_authentication(options)
      new_user.password = SecureRandom.base64(10).to_s # set a random strong password so user's account cannot be accessed manually
      new_user.is_password_set = false # this lets us know that the user does not have a password
      Rails.logger.info new_user.errors.full_messages
      Rails.logger.info new_user.account.errors.full_messages
      return new_user if new_user.save
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

  protected 

  def build_account_when_creating_new_user
    unless self.account.present?
      self.build_account
      self.account.user = self # setup back reference so account can access email prior to creation
    end
  end
  
end
