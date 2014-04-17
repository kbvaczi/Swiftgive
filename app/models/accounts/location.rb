class Accounts::Location
  include ActiveModel::Validations 

  validates_presence_of :city, :state
                        
  # to deal with form, you must have an id attribute
  attr_accessor :id, :city, :state

  def initialize(attributes = {})
    if attributes.present?
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end
    @attributes = attributes || {}
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
    {:city => self.city, :state => self.state}
  end

  def self.required_inputs
    [:city, :state]
  end

  def to_key; end

  def persisted? 
    false
  end
  
  def save
    if self.valid? and current_user.account.update_attributes(self.attributes)
      return true
    else
      return false
    end
  end
  
end