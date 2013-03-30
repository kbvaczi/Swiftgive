class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
    
  has_many    :memberships,   :class_name => 'Funds::Membership', :foreign_key => :fund_id, :dependent => :destroy
  has_many    :members,       :class_name => "User",              :through => :memberships, :source => :member
  
  attr_accessible :name, :description, :profile,
                  :stripe_access_token, :stripe_refresh_token, :stripe_publishable_key, 
                  :stripe_user_id, :stripe_omniauth_response

  attr_accessor   :loaded_stripe_omniauth_response

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description,
                        :stripe_access_token, :stripe_refresh_token, :stripe_publishable_key, 
                        :stripe_user_id, :stripe_omniauth_response
                        
  # ----- Callbacks ----- #    
  
  before_create :yaml_convert_sripe_omniauth_response
  
  # stores data as YAML string in database.  Doing this manually because it's a lot faster than serialize attribute added to class.  
  # Serialize YAML loads every time class object is instantiated, this loads only when field is called.
  def yaml_convert_sripe_omniauth_response
    omniauth_response_data_hash = read_attribute :stripe_omniauth_response
    write_attribute :stripe_omniauth_response, omniauth_response_data_hash.to_yaml if omniauth_response_data_hash.class.name == 'Hash'
  end
    
  # ----- Member Methods ----- #

  def stripe_omniauth_response
    self.loaded_stripe_omniauth_response ||= YAML.load read_attribute :stripe_omniauth_response
  end
  
  # ----- Class Methods ----- #
  
  
end

f = Fund.new(name: 'test', description: 'whatever', profile: 'profile', stripe_access_token: '2', stripe_refresh_token: '2', stripe_publishable_key: '2', stripe_user_id: '2', stripe_omniauth_response: '2')
