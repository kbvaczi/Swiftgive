class Payment < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to  :fund,               :class_name => 'Fund'
  belongs_to  :sender,             :class_name => 'Account'
  belongs_to  :payment_card_used,  :class_name => 'Accounts::PaymentCard'
  
  attr_accessible :amount, :message, :is_anonymous, :fund_id, :payment_card_used_attributes

  accepts_nested_attributes_for :payment_card_used
  
  # ----- Validations ----- #
  
  validates_presence_of :uid, :sender, :fund, :payment_card_used, :amount
  validates_associated  :payment_card_used, :sender
  validate              :create_balanced_payment, :on => :create, :unless => Proc.new { self.balanced_uri.present? }  
                          
  # ----- Callbacks ----- #

  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid, :on => :create, :unless => Proc.new { self.uid.present? }
      
  # ----- Member Methods ----- #

  def associated_balanced_payment
    Rails.logger.debug "External Call: Finding Balanced Payment"
    Balanced::Debit.find(self.balanced_uri)
  end

  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'p_' + SecureRandom.hex(5)
      break random_uid unless self.class.where(uid: random_uid).exists?
    end
  end
  
  def create_balanced_payment
    begin
      Rails.logger.debug "External Call: Creating Debit in Balanced Payment System"
      balanced_payment = self.sender.associated_balanced_account.debit(
        :appears_on_statement_as => "Swiftgive: #{self.fund.name.first(11)}",
        :amount => self.amount,
        :description => "Swiftgive to #{self.fund.name} for #{self.amount}",
        :source_uri => self.payment_card_used.balanced_uri,
        #TODO: add functionality for on_behalf_of_uri and meta information
        :meta => nil,
        :on_behalf_of_uri => self.fund.balanced_uri
      )
      self.balanced_uri = balanced_payment.uri
    rescue Balanced::Error => error
      Rails.logger.info("ERROR CREATING BALANCED PAYMENT: #{error.message}")
      errors.add(:balanced_uri, error.message)
    end    
  end

end
