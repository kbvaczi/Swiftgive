class Funds::Membership < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds_memberships'
  
  belongs_to  :member,        :class_name => 'Account', :foreign_key => :account_id
  belongs_to  :fund,          :class_name => 'Fund',		:foreign_key => :fund_id
  
  attr_accessible :account_id, :fund_id

  # ----- Validations ----- #
                        
  # ----- Callbacks ----- #    
    
  # ----- Member Methods ----- #

  # ----- Class Methods ----- #
  
  
end
