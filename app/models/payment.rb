class Payment < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to  :fund,          :class_name => 'Fund'
  belongs_to  :sender,        :class_name => 'User'  
  
  attr_accessible :uid, :amount, :message, :is_anonymous, :fund_id

  attr_accessor :category, :payment_preset
  
  # ----- Validations ----- #

  validates_presence_of :uid, :amount
                        
  # ----- Callbacks ----- #

  before_validation :generate_and_assign_uid, :on => :create
      
  # ----- Member Methods ----- #

  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'p_' + SecureRandom.hex(5)
      break random_uid unless User.where(uid: random_uid).exists?
    end
  end
  
end
