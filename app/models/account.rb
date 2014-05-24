class Account < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :user

  attr_accessible :first_name, :last_name, :state, :city, :avatar

  mount_uploader :avatar, AccountAvatarUploader

  # ----- Validations ----- #
           
  validates_presence_of   :first_name,    :if => 'self.first_name_changed? and self.persisted?'  # allows users to sign in via username and password without setting first/last name
  validates_presence_of   :last_name,     :if => 'self.last_name_changed? and self.persisted?'   # allows users to sign in via username and password without setting first/last name
  validates               :first_name, :last_name, :length => { :maximum => 30 }
  
  # ----- Callbacks ----- #

  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid,           :on => :create, :unless => Proc.new { self.uid.present? }

  # ----- Member Methods ----- #
  
  # returns full name of user
  def full_name
    if self.first_name.present? and self.last_name.present?
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name
    end
  end
  
  def location
    inputs_list = {}
    Accounts::Location.required_inputs.each do |input_symbol|
      inputs_list.merge!(input_symbol => self[input_symbol])
    end
    location = Accounts::Location.new(inputs_list)
  end
  
  # ----- Class Methods ----- #

  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    unless self.uid.present?
      self.uid = loop do
        random_uid = 'ACCT_' + SecureRandom.hex(5)
        break random_uid unless Account.unscoped.where(uid: random_uid).exists?
      end
    end
  end

end
