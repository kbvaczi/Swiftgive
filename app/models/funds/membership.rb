class Funds::Membership < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds_memberships'
  
  belongs_to  :member,        :class_name => 'User', 		:foreign_key => :user_id
  belongs_to  :fund,          :class_name => 'Fund',		:foreign_key => :fund_id
  
  attr_accessible :user_id, :fund_id

  # ----- Validations ----- #
                        
  # ----- Callbacks ----- #    
    
  # ----- Member Methods ----- #

  # ----- Class Methods ----- #
  
  
end
