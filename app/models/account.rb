class Account < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :user
  has_many    :payments,          :class_name => 'Payment',               :foreign_key => :sender_id
  has_many    :fund_memberships,  :class_name => 'Funds::Membership'
  has_many    :funds,             :class_name => 'Fund',                  :through => :fund_memberships

  attr_accessible :first_name, :last_name, :state, :city, :avatar, :email_from_user

  attr_accessor :email_from_user

  mount_uploader :avatar, AccountAvatarUploader

  # ----- Validations ----- #
           
  validates_presence_of   :first_name,    :if => 'self.first_name_changed? and self.persisted?'  # allows users to sign in via username and password without setting first/last name
  validates_presence_of   :last_name,     :if => 'self.last_name_changed? and self.persisted?'   # allows users to sign in via username and password without setting first/last name
  
  # ----- Callbacks ----- #

  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid,           :on => :create, :unless => Proc.new { self.uid.present? }

  # ----- Member Methods ----- #
  
  # returns full name of user
  def full_name
    "#{self.first_name} #{self.last_name}"
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
        break random_uid unless Account.where(uid: random_uid).exists?
      end
    end
  end

end
