class Payment < ActiveRecord::Base

  # ----- Table Setup ----- #

  belongs_to  :fund,               :class_name => 'Fund'
  belongs_to  :sender,             :class_name => 'Account'
  
  attr_accessor :amount_in_dollars

  attr_accessible :amount_in_cents, :message, :is_anonymous, :fund_id, :amount_in_dollars, :sender_email, :receiver_email, :sender_name_from_email
  
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


  # ----- Member Methods ----- #  


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
