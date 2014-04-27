class Payment < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to  :fund,               :class_name => 'Fund'
  belongs_to  :sender,             :class_name => 'Account'
  
  attr_accessor :amount_in_dollars

  attr_accessible :amount_in_cents, :message, :is_anonymous, :fund_id, :amount_in_dollars, :sender_email, :receiver_email
  
  def to_param
    self.uid.parameterize
  end
  
  # ----- Validations ----- #
  
  validates_presence_of   :uid, :fund, :amount_in_cents
  validate                Proc.new {self.amount_in_dollars = self.amount_in_dollars.to_i} if 'self.amount_in_dollars.present?'
  validates_inclusion_of  :amount_in_dollars, :in => 1..1000, :allow_nil => true, :message => 'Must be between $1 and $1000'
  validates_inclusion_of  :amount_in_cents, :in => 100..100000, :message => 'Must be between $1 and $1000', :allow_nil => false
                        
  # ----- Callbacks ----- #

  after_initialize  Proc.new { self.amount_in_dollars = self.amount_in_cents.to_f / 100 }
  before_validation Proc.new { Rails.logger.debug "Validating #{self.class.name}" }
  before_validation :generate_and_assign_uid, :on => :create, :unless => Proc.new { self.uid.present? }
      
  # ----- Scopes ----- #

  default_scope where(:is_cancelled => false)

  # ----- Member Methods ----- #  

  def confirm_by_email(mail_object)
    if mail_object.class.name == "Mail::Message"
      sender_address    = mail_object.from.first
      sender_name       = mail_object[:from].decoded[/(.+) \</, 1]
      to_addresses      = mail_object.to
      cc_addresses      = mail_object.cc
      subject           = mail_object.subject
      amount_in_cents   = (subject[/( |^)\$(\d+\.?\d{,2})( |$)/, 2].to_f * 100).to_i # there must be spaces around dollar amount for square cash to recognize
      is_square_cash_copied = cc_addresses.any?{ |s| s.casecmp("cash@square.com") == 0 } # square cash must be copied for valid payment
      is_only_one_receiver  = to_addresses.length == 1 # square cash allows 1 receiver maximum otherwise payment won't go through
      is_valid_receiver     = (to_addresses.first.downcase == self.fund.business_email.downcase) or (to_addresses.first.downcase.in?(self.fund.members(:includes => :user).collect {|account| account.user.email.downcase}))
      if is_square_cash_copied and is_only_one_receiver and is_valid_receiver and amount_in_cents.present?
        self.update_attributes({:receiver_email => to_addresses.first, :sender_email => sender_address, :amount_in_cents => amount_in_cents, :is_confirmed_by_email => true, :sender_name_from_email => sender_name}, :without_protection => true)
      else
        self.update_attribute(:is_cancelled, true)
      end
    end
  end

  # ----- Class Methods ----- #

  def self.column_keys 
    self.column_names.collect { |c| c.to_sym }
  end

  # ----- Protected Methods ----- #

  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'p_' + SecureRandom.hex(5)
      break random_uid unless self.class.where(uid: random_uid).exists?
    end
  end

end
