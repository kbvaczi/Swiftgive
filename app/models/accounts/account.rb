class Account < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :user
  has_many    :payment_cards,     :class_name => 'Accounts::PaymentCard',    :dependent => :destroy
  has_many    :payments,          :class_name => 'Payment',               :foreign_key => :sender_id
  has_many    :bank_accounts,     :class_name => 'BankAccount',           :dependent => :destroy
  has_many    :fund_memberships,  :class_name => 'Funds::Membership'
  has_many    :funds,             :class_name => 'Fund',                  :through => :fund_memberships

  attr_accessible :first_name, :last_name, :country, :state, :city, :street_address, :zipcode, :avatar
    
  # ----- Validations ----- #
  
  validates_presence_of  :balanced_uri, :message => 'We could not verify you with our payment processor'
  #validates             :state, :format => { :with => /\A[A-Z]{2}\z/, :message => "Please enter a valid State Abbreviation" }  
  #validates             :zipcode, :format => { :with => /\A\d{5}\z/, :message => "Please enter a valid 5 digit zipcode" } # matches 5-digit US zipcodes only
  #validates             :country, :format => { :with => /\A[a-zA-Z .]+\z/, :message => "Only letters allowed" }

  # ----- Callbacks ----- #                      

  before_validation :generate_and_assign_uid, :on => :create
  before_validation :create_balanced_payments_account_and_set_balance, :on => :create
   
  # ----- Member Methods ----- #
  
  # returns full name of user
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def associated_balanced_account
    Balanced::Account.find(self.balanced_uri)
  end
  
  # ----- Class Methods ----- #

  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'ACCT_' + SecureRandom.hex(5)
      break random_uid unless Account.where(uid: random_uid).exists?
    end
  end

  def create_balanced_payments_account_and_set_balance
    begin
      account = Balanced::Marketplace.my_marketplace.create_account(:email_address => (self.user.present? ? self.user.email : nil), :name => self.full_name)
    rescue Balanced::Error => error
      Rails.logger.info("ERROR CREATING BALANCE ACCOUNT: #{error}")
      account = Balanced::Account.where(:email_address => self.user.email).first rescue nil
    end
    self.balanced_uri = account.uri if account.present?
    self.current_balance = 0
  end

end
