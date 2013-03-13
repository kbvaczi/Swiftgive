class Users::Authentication < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'users_authentications'
  
  belongs_to :user
  
  attr_accessible :uid, :provider, :omniauth_data
  
  validates_presence_of :uid, :provider
  
  # ----- Member Methods ----- #
  
  # ----- Class Methods ----- #
  
  
end
