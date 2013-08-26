class Users::RegistrationsController < Devise::RegistrationsController
  
  include Mobylette::RespondToMobileRequests  
  
   def update
    # Override Devise to use update_attributes instead of update_with_password if no password is sent
    is_password_confirmation_required = ( (params[resource_name].keys.include?('password') or params[resource_name].keys.include?('password')) and resource.is_password_set )
    if is_password_confirmation_required
      was_updated_successfully = resource.update_with_password(params[resource_name])
    else
      resource.assign_attributes(params[resource_name])
      resource.is_password_set = true if resource.encrypted_password_changed?
      was_updated_successfully = resource.save
    end
    if was_updated_successfully
      set_flash_message :notice, :updated
      # Line below required if using Devise >= 1.2.0
      sign_in resource_name, resource, :bypass => true
      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      flash[:error] = 'Error updating your profile...'
      redirect_to back_path
    end
  end
    
  # devise redirect after sign up
  def after_inactive_sign_up_path_for(resource)
    if resource.is_a?(User)
      back_path
    else
      super
    end
  end    
  
  # devise redirect after account update
  def after_update_path_for(resource)
    case resource
    when :user, User  
      back_path
    else
      super
    end
  end
  
end
