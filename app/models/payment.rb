class Payment < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to  :fund,               :class_name => 'Fund'
  belongs_to  :sender,             :class_name => 'Account'
  belongs_to  :payment_card_used,  :class_name => 'Accounts::PaymentCard'
  
  attr_accessible :uid, :amount, :message, :is_anonymous, :fund_id, :payment_card_used_attributes

  attr_accessor :category, :payment_preset

  accepts_nested_attributes_for :payment_card_used
  
  # ----- Validations ----- #

  validates_presence_of :uid, :amount, :payment_card_used
  validates_associated :payment_card_used
                        
  # ----- Callbacks ----- #

  before_validation :generate_and_assign_uid, :on => :create
      
  # ----- Member Methods ----- #

  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'p_' + SecureRandom.hex(5)
      break random_uid unless Payment.where(uid: random_uid).exists?
    end
  end
  
end
