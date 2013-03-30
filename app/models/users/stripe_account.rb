class Users::StripeAccount < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'users_stripe_accounts'
  
  belongs_to :user
    
  # ----- Member Methods ----- #

  
  # ----- Class Methods ----- #
  
  
end
