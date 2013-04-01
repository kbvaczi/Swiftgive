class Funds::StripeAccount < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds_stripe_accounts'
  
  belongs_to  :fund,          :class_name => 'Fund'
  
  attr_accessible :stripe_access_token, :stripe_refresh_token, :stripe_publishable_key, 
                  :stripe_user_id, :stripe_access_response

  attr_accessor   :loaded_stripe_access_response

  # ----- Validations ----- #

  validates_uniqueness_of :fund_id, :message => 'Fund already linked to a funding account...'
                        
  # ----- Callbacks ----- #
    
  # stores data as YAML string in database.  Doing this manually because it's a lot faster than serialize attribute added to class.  
  # Serialize YAML loads every time class object is instantiated, this loads only when field is called.
  before_create :yaml_convert_sripe_access_response  
  def yaml_convert_sripe_access_response
    access_response_data_hash = read_attribute :stripe_access_response
    write_attribute :stripe_access_response, access_response_data_hash.to_yaml if access_response_data_hash.class.name == 'Hash'
  end
    
  # ----- Member Methods ----- #

  def stripe_access_response
    self.loaded_stripe_access_response ||= YAML.load(read_attribute :stripe_access_response)
  end

  # ----- Class Methods ----- #
  
  
end
