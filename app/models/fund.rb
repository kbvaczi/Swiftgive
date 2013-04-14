class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
    
  has_many    :memberships,     :class_name => 'Funds::Membership', :foreign_key => :fund_id, :dependent => :destroy
  has_many    :members,         :class_name => "User",              :through => :memberships, :source => :member
  has_many    :ownerships,      :class_name => 'Funds::Membership', :foreign_key => :fund_id, :conditions => {:is_owner => true}  
  has_many    :owners,          :class_name => "User",              :through => :ownerships,  :source => :member
  
  has_many    :bank_accounts,   :class_name => 'BankAccount',       :dependent => :destroy
  
  has_many    :payments,        :class_name => 'Payment',    :dependent => :destroy
  
  attr_accessible :name, :description, :profile

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description
                        
  # ----- Callbacks ----- #    

  before_validation :generate_and_assign_uid, :on => :create
    
  # ----- Member Methods ----- #
  
  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #
  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'f_' + SecureRandom.hex(3)
      break random_uid unless User.where(uid: random_uid).exists?
    end
  end
  
end
