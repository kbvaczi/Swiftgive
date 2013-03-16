class Users::Authentication < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'users_authentications'
  
  belongs_to :user
  
  attr_accessible :uid, :provider, :omniauth_data
  
  validates_presence_of :uid, :provider
  validate :only_one_provider_per_user, :on => :create
  
  def only_one_provider_per_user
    if self.user.present? and self.user.authentications.where(:provider => self.provider).present?    
      errors[:provider] << "There is already a #{self.provider} account linked to your profile..."
    end
  end
  
  # ----- Member Methods ----- #

  
  # ----- Class Methods ----- #
  
  
end
