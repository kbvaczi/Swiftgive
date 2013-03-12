class Users::Authentication < ActiveRecord::Base
  self.table_name = 'users_authentications'
  
  belongs_to :user
  
  attr_accessible :uid, :provider, :omniauth_data
  
  validates_presence_of :uid, :provider
  
end
