class Payment < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to  :fund,               :class_name => 'Fund'
  belongs_to  :sender,             :class_name => 'User'
  
  attr_accessor :amount_in_dollars

  attr_accessible :amount_in_cents, :message, :is_anonymous, :fund_id, :amount_in_dollars, :sender_email, :receiver_email
  
  def to_param
    self.uid.parameterize
  end
  
  # ----- Validations ----- #
  
  validates_presence_of   :uid, :fund, :amount_in_cents
  validate                Proc.new {self.amount_in_dollars = self.amount_in_dollars.to_i}, :if => 'self.amount_in_dollars.present?'
  validates_inclusion_of  :amount_in_dollars, :in => 1..1000, :allow_nil => true, :message => 'Must be between $1 and $1000'
  validates_inclusion_of  :amount_in_cents, :in => 100..100000, :message => 'Must be between $1 and $1000', :allow_nil => false
                        
  # ----- Callbacks ----- #

  after_initialize  Proc.new { self.amount_in_dollars = self.amount_in_cents.to_f / 100 }
  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid, :on => :create, :unless => Proc.new { self.uid.present? }
  before_create     Proc.new { self.is_anonymous = true unless self.sender.present? }
      
  # ----- Scopes ----- #

  default_scope { confirmed_by_email.not_cancelled }
  
  scope :confirmed_by_email,  where(:is_confirmed_by_email => true)
  scope :unconfirmed,         where(:is_confirmed_by_email => false)
  scope :not_cancelled,       where(:is_cancelled => false)
  scope :cancelled,           where(:is_cancelled => true)

  # ----- Member Methods ----- #  

  def confirm_by_email(sender_address, sender_name, to_addresses, cc_addresses, subject, amount_in_cents)
    if sender_address.present? and sender_name.present? and to_addresses.present? and cc_addresses.present? and subject.present? and amount_in_cents.present?
      is_square_cash_copied   = cc_addresses.any?{ |s| s.casecmp("cash@square.com") == 0 } # square cash must be copied for valid payment
      is_only_one_receiver    = to_addresses.length == 1 # square cash allows 1 receiver maximum otherwise payment won't go through
      is_valid_receiver       = ((to_addresses.first.downcase == self.fund.receiver_email.downcase) or (to_addresses.first.downcase.in?(self.fund.members.collect {|user| user.email.downcase})))
      is_not_sending_to_self  = to_addresses.first.downcase != sender_address.downcase
      if not is_square_cash_copied
        self.update_attributes({:is_cancelled => true, :reason_for_cancellation => 'square cash not copied on email'}, :without_protection => true)
      elsif not is_only_one_receiver
        self.update_attributes({:is_cancelled => true, :reason_for_cancellation => 'multiple receivers not allowed'}, :without_protection => true)
      elsif not is_valid_receiver
        self.update_attributes({:is_cancelled => true, :reason_for_cancellation => 'invalid receiver email'}, :without_protection => true)
      elsif not amount_in_cents.present?
        self.update_attributes({:is_cancelled => true, :reason_for_cancellation => 'payment amount missing in heading'}, :without_protection => true)
      elsif not is_not_sending_to_self
        self.update_attributes({:is_cancelled => true, :reason_for_cancellation => 'cannot send payments to yourself'}, :without_protection => true)        
      else
        self.update_attributes({:receiver_email => to_addresses.first, :sender_email => sender_address, :amount_in_cents => amount_in_cents, :is_confirmed_by_email => true, :sender_name_from_email => sender_name}, :without_protection => true)      
      end
    end
  end

  # ----- Class Methods ----- #

  def self.cancel_old_payments
    Payment.unconfirmed.where("created_at < ?", 1.day.ago).update_all(:is_cancelled => true, :reason_for_cancellation => 'no payment email sent')
  end

  def self.column_keys 
    self.column_names.collect { |c| c.to_sym }
  end

  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'p_' + SecureRandom.hex(5)
      break random_uid unless self.class.unscoped.where(uid: random_uid).exists?
    end
  end

end
