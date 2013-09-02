class Accounts::PaymentCard < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'accounts_payment_cards'
  
  belongs_to :account,  :class_name => 'Account'
  has_many   :payments, :class_name => 'Payment'

  attr_accessible :balanced_uri
  
  attr_accessor :is_validated_by_balanced, :associated_balanced_card, :is_added_to_balanced_customer, :balanced_hash, :remember_card
  
  # ----- Validations ----- #
  
  validates_presence_of   :balanced_uri, :message => 'please select a payment card'
  validates_uniqueness_of :balanced_uri # necessary to prevent card stealing from someone obtaining a card's balanced_uri
  validate                :validate_card_with_balanced,              :on => :create, :unless => Proc.new { self.is_validated_by_balanced }
  validate                :add_associated_balanced_card_to_customer, :on => :create, :unless => Proc.new { self.is_added_to_balanced_customer }  

  # ----- Callbacks ----- #  
  
  before_validation       Proc.new { Rails.logger.debug "Validating #{self.class.name}" }  
  before_destroy          :invalidate
    
  # ----- Scopes ----- #

  scope :active, where(:is_active => true)
  scope :inactive, where(:is_active => false)
  default_scope active

  # ----- Member Methods ----- #
  
  def associated_balanced_card
    if @associated_balanced_card.present?
      @associated_balanced_card
    else
      @associated_balanced_card = Balanced::Card.find(self.balanced_uri) 
    end
  end

  def validate_card_with_balanced
    Rails.logger.debug "External call: Validating Payment Card with Balanced Payments Service"
    card_data_from_balanced = self.associated_balanced_card
    if card_data_from_balanced.present? and card_data_from_balanced.is_valid?
      self.assign_attributes({:card_type => card_data_from_balanced.brand, 
                              :last_4_digits => card_data_from_balanced.last_four,
                              :name_on_card => card_data_from_balanced.name,
                              :balanced_hash => card_data_from_balanced.hash,
                              :is_validated_by_balanced => card_data_from_balanced.is_valid}, :without_protection => true)
    else
      errors.add(:balanced_uri, "Card could not be validated...")
    end
  end

  def invalidate
    self.associated_balanced_card.invalidate
    self.update_attribute(:is_active, false)
  end
  
  # ----- Class Methods ----- #
  
  def self.column_keys 
    self.column_names.collect { |c| c.to_sym }
  end

  protected 

  def add_associated_balanced_card_to_customer
    if self.account.new_record?
      sender_first_name = self.name_on_card.split.first
      sender_last_name  = self.name_on_card.split.last
      self.account.assign_attributes(:first_name => sender_first_name, :last_name => sender_last_name) 
    end
    if self.account.valid?
      Rails.logger.debug "External call: Adding Payment Card to Balanced Customer"
      if self.account.associated_balanced_customer.add_card(self.balanced_uri)
        self.is_added_to_balanced_customer = true
      else
        errors.add(:account_id, "Could not add card to customer")
      end
    else
      errors.add(:account_id, "Could not add card to customer")
    end
  end
  
end
