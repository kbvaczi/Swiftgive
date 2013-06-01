class Accounts::PaymentCard < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'accounts_payment_cards'
  
  belongs_to :account,  :class_name => 'Account'
  has_many   :payments, :class_name => 'Payment'

  attr_accessible :balanced_uri
  
  attr_accessor :is_validated_by_balanced, :associated_balanced_card, :is_added_to_balanced_account
  
  # ----- Validations ----- #
  
  validate                :validate_card_with_balanced,             :on => :create, :unless => Proc.new { self.is_validated_by_balanced }
  validates_presence_of   :balanced_uri
  validates_uniqueness_of :balanced_uri
  validate                :add_associated_balanced_card_to_account, :on => :create, :unless => Proc.new { self.is_added_to_balanced_account }  
  
  # ----- Callbacks ----- #
  
  before_validation       Proc.new { Rails.logger.debug "Validating #{self.class.name}" }  
  after_destroy           :invalidate_associated_balanced_card
    
  # ----- Member Methods ----- #
  
  def associated_balanced_card
    if @associated_balanced_card.present?
      @associated_balanced_card
    else
      @associated_balanced_card = Balanced::Card.find(self.balanced_uri) 
    end
  end
  
  # ----- Class Methods ----- #
  
  protected
  
  def validate_card_with_balanced
    Rails.logger.debug "External call: Validating Payment Card with Balanced Payments Service"
    card_data_from_balanced = self.associated_balanced_card
    if card_data_from_balanced.present? and card_data_from_balanced.is_valid?
      self.assign_attributes({:card_type => card_data_from_balanced.brand, 
                              :last_4_digits => card_data_from_balanced.last_four,
                              :name_on_card => card_data_from_balanced.name,
                              :is_validated_by_balanced => card_data_from_balanced.is_valid}, :without_protection => true)
    else
      errors.add(:balanced_uri, "Card could not be validated...")
    end
  end

  def add_associated_balanced_card_to_account
    if self.account.new_record?
      sender_first_name = self.name_on_card.split.first
      sender_last_name  = self.name_on_card.split.last
      self.account.assign_attributes(:first_name => sender_first_name, :last_name => sender_last_name) 
    end
    if self.account.valid?
      Rails.logger.debug "External call: Adding Payment Card to Balanced Account"
      if self.account.associated_balanced_account.add_card(self.balanced_uri)
        self.is_added_to_balanced_account = true
      else
        errors.add(:account_id, "Could not add card to account")
      end
    end
  end

  def invalidate_associated_balanced_card
    self.associated_balanced_card.invalidate
  end

  
end