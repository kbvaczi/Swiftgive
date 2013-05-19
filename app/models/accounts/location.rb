class Accounts::Location
  include ActiveModel::Validations 

  validates_presence_of :street_address, :postal_code, :city, :state, :country
                        
  # to deal with form, you must have an id attribute
  attr_accessor :id, :street_address, :postal_code, :city, :state, :country

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    @attributes = attributes
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

  def attributes
    {:street_address => self.street_address, :city => self.city, :state => self.state, :postal_code => self.postal_code, :country => self.country}
  end

  def to_key; end

  def save
    if self.valid? and current_user.update_attributes(self.attributes)
      return true
    else
      return false
    end
  end
  
end