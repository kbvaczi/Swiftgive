class Users::PaymentCard < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'users_payment_cards'
  
  belongs_to :user

  attr_accessible :uri, :card_type, :last_4_digits, :is_valid
  
  attr_accessor :is_valid
  
  # ----- Validations ----- #
  validates_presence_of :uri, :card_type, :last_4_digits  
    
  # ----- Callbacks ----- #  
  
  before_create :add_associated_balanced_card_to_account
    
  # ----- Member Methods ----- #
  
  def associated_balanced_card
    Balanced::Card.find(self.uri)
  end
  
  # ----- Class Methods ----- #
  
  
  protected
  
  def add_associated_balanced_card_to_account
    self.user.balanced_account.add_card(self.uri)
  end

  
end
