class Users::PaymentCard < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'users_payment_cards'
  
  belongs_to :user

  attr_accessible :stripe_customer_id, :stripe_customer_object

  attr_accessor :loaded_stripe_customer_object
  
  # ----- Validations ----- #
  validates_presence_of :stripe_customer_id, :stripe_customer_object
    
  # ----- Callbacks ----- #  
  before_create :yaml_convert_stripe_customer_object
  
  # stores data as YAML string in database.  Doing this manually because it's a lot faster than serialize attribute added to class.  
  # Serialize YAML loads every time class object is instantiated, this loads only when field is called.
  def yaml_convert_stripe_customer_object
    current_customer_object_data = read_attribute :stripe_customer_object
    write_attribute :stripe_customer_data, current_customer_object_data.to_yaml if current_customer_object_data.class.name == 'Stripe::Customer'
  end
    
  # ----- Member Methods ----- #

  def stripe_customer_object
    self.loaded_stripe_customer_object ||= YAML.load(read_attribute :stripe_customer_object)
  end
  
  # ----- Class Methods ----- #
  
  
end
