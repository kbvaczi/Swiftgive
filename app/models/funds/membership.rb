class Funds::Membership < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds_memberships'
  
  belongs_to  :member,        :class_name => 'User', :foreign_key => :user_id
  belongs_to  :fund,          :class_name => 'Fund'
  
  attr_accessible :member_id, :fund_id

  # ----- Validations ----- #
                        
  # ----- Callbacks ----- #    
    
  # ----- Member Methods ----- #

  # ----- Class Methods ----- #
  
  
end
