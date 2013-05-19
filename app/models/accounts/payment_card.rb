class Accounts::PaymentCard < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'accounts_payment_cards'
  
  belongs_to :account,  :class_name => 'Account'
  has_many   :payments, :class_name => 'Accounts::Payment'

  attr_accessible :balanced_uri, :card_type, :last_4_digits, :is_valid
  
  #check is_valid from balanced prior to creating, but no need to store this value in model
  attr_accessor :is_valid 
  
  # ----- Validations ----- #
  
  validate :validate_card_with_balanced
  validates_presence_of :uri, :card_type, :last_4_digits
  
  def validate_card_with_balanced
    card_data_from_balanced = self.associated_balanced_card
    if card_data_from_balanced.present?
      self.assign_attributes(:card_type => card_data_from_balanced.brand, 
                             :last_4_digits => card_data_from_balanced.last_four, 
                             :is_valid => card_data_from_balanced.is_valid)
    else
      errors.add(:card_number, "Card not validated")
    end
  end

  # ----- Callbacks ----- #  

  before_create :add_associated_balanced_card_to_account
    
  # ----- Member Methods ----- #
  
  def associated_balanced_card
    Balanced::Card.find(self.uri)
  end
  
  # ----- Class Methods ----- #
  
  protected
  
  def add_associated_balanced_card_to_account
    self.user.balanced_account.add_card(self.uri) if self.user.present?
  end

  
end
