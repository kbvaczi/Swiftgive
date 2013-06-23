class BankAccount < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :account
  belongs_to :fund

  attr_accessible :balanced_uri
    
  attr_accessor :is_validated_by_balanced
    
  # ----- Validations ----- #

  validate                :validate_account_with_balanced, :on => :create, :unless => Proc.new { self.is_validated_by_balanced }
  validates_presence_of   :balanced_uri, :account_type, :owner_name, :bank_name, :last_4_digits
  validates_uniqueness_of :balanced_uri
    
  # ----- Callbacks ----- #
  
  before_validation       Proc.new { Rails.logger.debug "Validating #{self.class.name}" }  
  before_destroy          :invalidate_associated_balanced_bank_account
  before_create           :add_balanced_customer_to_merchant_account
    
  # ----- Member Methods ----- #
  
  def associated_balanced_bank_account
    Balanced::BankAccount.find(self.balanced_uri)
  end

  def validate_account_with_balanced
    Rails.logger.debug "External call: Validating Bank Account with Balanced Payments Service"
    account_data_from_balanced = self.associated_balanced_bank_account
    if account_data_from_balanced.present? and account_data_from_balanced.is_valid?
      self.assign_attributes({:bank_name => account_data_from_balanced.bank_name,
                              :account_type => account_data_from_balanced.type,
                              :owner_name => account_data_from_balanced.name,
                              :last_4_digits => account_data_from_balanced.last_four,
                              :is_debitable => account_data_from_balanced.can_debit,
                              :is_validated_by_balanced => account_data_from_balanced.is_valid}, :without_protection => true)
    else
      errors.add(:balanced_uri, "Bank account could not be validated...")
    end
  end
  
  # ----- Class Methods ----- #

  protected

  def add_balanced_customer_to_merchant_account
    self.fund.associated_balanced_customer.add_bank_account(self.associated_balanced_bank_account.uri)
  end
  
  def invalidate_associated_balanced_bank_account
    self.associated_balanced_bank_account.invalidate
  end
  
            
end
