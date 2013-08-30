class Accounts::PaymentCardSubmission
  include ActiveModel::Validations 
						
  # to deal with form, you must have an id attribute
  attr_accessor :card_number, :name_on_card, :expiration_month, :expiration_year, :security_code, :postal_code, :remember_card

  validates_presence_of :card_number, :name_on_card, :expiration_month, :expiration_year, :security_code, :postal_code

  def initialize(attributes = {})
		if attributes.present?
		  attributes.each do |key, value|
			self.send("#{key}=", value)
		  end
		end
		@attributes = attributes || {}
		@remember_card = true unless @remember_card == false # default remember card
  end

  def update_attributes(attributes = {})
		attributes.each do |key, value|
		  self.send("#{key}=", value)
		end
		@attributes = @attributes.merge(attributes)
  end

  def read_attribute_for_validation(key)
		@attributes[key]
  end

  def to_key; end

  def persisted? 
		false
  end

  def self.default_values_for_testing
		{ :card_number => 4111111111111111,
			:postal_code => 12345,
			:name_on_card => 'John Appleseed',
			:security_code => 123,
			:expiration_month => 1,
			:expiration_year => 2020 }
  end
  
end