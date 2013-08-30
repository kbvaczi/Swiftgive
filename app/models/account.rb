class Account < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :user
  has_many    :payment_cards,     :class_name => 'Accounts::PaymentCard',    :dependent => :destroy
  has_many    :payments,          :class_name => 'Payment',               :foreign_key => :sender_id
  has_many    :bank_accounts,     :class_name => 'BankAccount',           :dependent => :destroy
  has_many    :fund_memberships,  :class_name => 'Funds::Membership'
  has_many    :funds,             :class_name => 'Fund',                  :through => :fund_memberships

  attr_accessible :first_name, :last_name, :date_of_birth, :country, :state, :city, :street_address, :postal_code, :avatar, :email_from_user

  attr_accessor :email_from_user
  attr_accessor :associated_balanced_customer

  mount_uploader :avatar, AccountAvatarUploader

  # ----- Validations ----- #
           
  validates_presence_of   :balanced_uri,  :message => 'We could not verify you with our payment processor'
  validates_presence_of   :first_name,    :if => 'self.first_name_changed? and self.persisted?'
  validates_presence_of   :last_name,     :if => 'self.last_name_changed? and self.persisted?'
  validates_presence_of   :date_of_birth, :if => 'self.date_of_birth_changed? and self.persisted?'
  validates               :date_of_birth, :inclusion => { :in => Proc.new { 90.years.ago.to_date..15.years.ago.to_date }, :message => 'Minimum age is 15 years' }
  
  # ----- Callbacks ----- #              

  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid,           :on => :create, :unless => Proc.new { self.uid.present? }
  before_validation :create_balanced_payments_customer, :on => :create, :unless => Proc.new { self.balanced_uri.present? }
  before_validation :set_balance_to_zero,               :on => :create
  before_update     :update_balanced_payments_customer
   
  # ----- Member Methods ----- #
  
  # returns full name of user
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def associated_balanced_customer
    if @associated_balanced_customer.present?
      @associated_balanced_customer
    else
      Rails.logger.debug "External call: Finding Customer"
      @associated_balanced_customer = Balanced::Customer.find(self.balanced_uri)
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
        break random_uid unless Account.where(uid: random_uid).exists?
      end
    end
  end

  def set_balance_to_zero
    self.current_balance_in_cents = 0
  end

  def create_balanced_payments_customer
    Rails.logger.debug "External call: Creating Balanced Payments Customer Object"
    begin
      @associated_balanced_customer = Balanced::Marketplace.my_marketplace.create_customer(:email => self.email_from_user, :name => self.full_name)
    rescue Balanced::Error => error
      Rails.logger.info("ERROR CREATING BALANCED CUSTOMER: #{error}")
      @associated_balanced_customer = Balanced::Customer.where(:email => self.email_from_user).first rescue nil
    end
    self.balanced_uri = @associated_balanced_customer.uri if @associated_balanced_customer.present?
  end

  def update_balanced_payments_customer
    associated_balanced_customer.name    = self.full_name
    associated_balanced_customer.email   = self.user.email
    associated_balanced_customer.dob     = self.date_of_birth
    associated_balanced_customer.address = { :line1 => self.street_address, :city => self.city, :state => self.state, :postal_code => self.postal_code, :country => self.country }
    associated_balanced_customer.save
  end

end
