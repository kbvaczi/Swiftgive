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
  before_validation :set_amounts,             :on => :create, :unless => Proc.new { self.amount_to_receiver.present? }
      
  # ----- Scopes ----- #

  scope :credited, where("#{self.table_name}.id > 0")
  #TODO: implemented credited scope for payment    
  #where(:is_outstanding => false)

  scope :credit_outstanding, where("#{self.table_name}.id > 0")
  #TODO: implemented credit outstanding scope for payment
  #where(:is_outstanding => true)
  

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
  
  def set_amounts
    self.balanced_fee       = (30 + 0.029 * self.amount).ceil
    self.commission_percent = self.fund.commission_percent || 0.05
    self.commission         = (self.commission_percent * self.amount).ceil
    self.amount_to_receiver = self.amount - self.balanced_fee - self.commission
  end

  def create_balanced_payment
    begin
      Rails.logger.debug "External Call: Creating Debit in Balanced Payment System"
      balanced_payment = self.sender.associated_balanced_account.debit(
        :appears_on_statement_as => "Swiftgive: #{self.fund.name.first(11)}",
        :amount => self.amount,
        :description => "Swiftgive to #{self.fund.name} for #{self.amount}",
        :source_uri => self.payment_card_used.balanced_uri,
        #TODO: add functionality for meta information
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
