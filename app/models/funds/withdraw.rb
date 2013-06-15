class Funds::Withdraw < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds_withdraws'

  belongs_to :bank_account
  belongs_to :fund

  attr_accessible :amount_in_cents
    
  # ----- Validations ----- #

  validates_presence_of   :amount_in_cents, :bank_account, :fund
  validate                :create_credit_in_balanced, :on => :create, :unless => Proc.new { self.errors.present? or self.balanced_uri.present? }
  validates_presence_of   :balanced_uri
  validates_uniqueness_of :balanced_uri
    
  # ----- Callbacks ----- #
  
  before_validation      Proc.new { Rails.logger.debug "Validating #{self.class.name}" }  
  before_validation      :generate_and_assign_uid, :on => :create, :unless => Proc.new { self.uid.present? }  
  before_validation      :set_amounts, :on => :create
  before_create          :mark_payments_as_credited
       
  # ----- Member Methods ----- #
  
  def associated_balanced_credit
    Balanced::Credit.find(self.balanced_uri)
  end
  
  # ----- Class Methods ----- #


  # ----- Protected Methods ----- #
  protected

  def mark_payments_as_credited
    Payment.mark_as_credited(self.fund.payments.credit_outstanding)
  end

  def create_credit_in_balanced
    Rails.logger.debug "External call: Creating Credit in Balanced"
    balanced_credit = self.bank_account.associated_balanced_bank_account.credit(:amount => self.amount_to_receiver_in_cents)
    if balanced_credit.present? and balanced_credit.uri.present?
      self.assign_attributes({:balanced_uri => balanced_credit.uri,
                              :status =>       balanced_credit.status}, :without_protection => true)
    else
      errors.add(:balanced_uri, "Withdraw cannot be processed at this time...")
    end
  end
  
  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'w_' + SecureRandom.hex(5)
      break random_uid unless self.class.where(uid: random_uid).exists?
    end
  end
  
  def set_amounts
    self.balanced_fee_in_cents = 25
    self.commission_in_cents   = 0
    self.amount_to_receiver_in_cents = self.amount_in_cents
  end
            
end
