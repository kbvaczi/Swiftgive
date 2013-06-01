class Account < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :user
  has_many    :payment_cards,     :class_name => 'Accounts::PaymentCard',    :dependent => :destroy
  has_many    :payments,          :class_name => 'Payment',               :foreign_key => :sender_id
  has_many    :bank_accounts,     :class_name => 'BankAccount',           :dependent => :destroy
  has_many    :fund_memberships,  :class_name => 'Funds::Membership'
  has_many    :funds,             :class_name => 'Fund',                  :through => :fund_memberships

  attr_accessible :first_name, :last_name, :country, :state, :city, :street_address, :zipcode, :avatar, :email_from_user

  attr_accessor :email_from_user
  attr_accessor :associated_balanced_account

  # ----- Validations ----- #
           
  validates_presence_of  :balanced_uri, :message => 'We could not verify you with our payment processor'

  #TODO: add validations for location information
  #validates             :state, :format => { :with => /\A[A-Z]{2}\z/, :message => "Please enter a valid State Abbreviation" }  
  #validates             :zipcode, :format => { :with => /\A\d{5}\z/, :message => "Please enter a valid 5 digit zipcode" } # matches 5-digit US zipcodes only
  #validates             :country, :format => { :with => /\A[a-zA-Z .]+\z/, :message => "Only letters allowed" }

  # ----- Callbacks ----- #              

  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid,           :on => :create, :unless => Proc.new { self.uid.present? }
  before_validation :create_balanced_payments_account,  :on => :create, :unless => Proc.new { self.balanced_uri.present? }
  before_validation :set_balance_to_zero,               :on => :create
   
  # ----- Member Methods ----- #
  
  # returns full name of user
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def associated_balanced_account
    if @associated_balanced_account.present?
      @associated_balanced_account
    else
      Rails.logger.debug "External call: Finding Account"
      @associated_balanced_account = Balanced::Account.find(self.balanced_uri)
    end
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
    self.current_balance = 0
  end

  def create_balanced_payments_account
    Rails.logger.debug "External call: Creating Balanced Payments Account"
    begin
      @associated_balanced_account = Balanced::Marketplace.my_marketplace.create_account(:email_address => self.email_from_user, :name => self.full_name)
    rescue Balanced::Error => error
      Rails.logger.info("ERROR CREATING BALANCE ACCOUNT: #{error}")
      @associated_balanced_account = Balanced::Account.where(:email_address => self.email_from_user).first rescue nil
    end
    self.balanced_uri = @associated_balanced_account.uri if @associated_balanced_account.present?
  end

end
