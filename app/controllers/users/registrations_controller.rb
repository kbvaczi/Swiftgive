class Users::RegistrationsController < Devise::RegistrationsController
  
  # devise redirect after sign up
  def after_inactive_sign_up_path_for(resource)
    if resource.is_a?(User)
      root_path
    else
      super
    end
  end    
  
  # devise redirect after account update
  def after_update_path_for(resource)
    case resource
    when :user, User  
      root_path
    else
      super
    end
  end
  
end
