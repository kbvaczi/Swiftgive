class Users::PasswordsController < Devise::PasswordsController
  
  include Mobylette::RespondToMobileRequests  
  
   def update    
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      # Handle event where person does not have a password set, resets password
      resource.update_attribute(:is_password_set, true) unless resource.is_password_set
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end
    
end
