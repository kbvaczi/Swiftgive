class BankAccount < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to :user
  belongs_to :fund

  attr_accessible :uri, :account_type, :bank_name, :owner_name, :last_4_digits, :is_debitable, :is_valid
    
  attr_accessor :is_valid
    
  # ----- Validations ----- #
  validates_presence_of :uri, :account_type, :owner_name, :bank_name, :last_4_digits
    
  # ----- Callbacks ----- #
  
  before_create  :add_associated_balanced_bank_account_to_account
  before_destroy :destroy_associated_balanced_bank_account
    
  # ----- Member Methods ----- #
  
  def associated_balanced_bank_account
    Balanced::BankAccount.find(self.uri)
  end
  
  # ----- Class Methods ----- #

  protected
  
  def add_associated_balanced_bank_account_to_account
    self.user.balanced_account.add_bank_account(self.uri)
  end
  
  def destroy_associated_balanced_bank_account
    self.associated_balanced_bank_account.destroy
  end
  
            
end
