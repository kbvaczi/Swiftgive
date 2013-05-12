class Users::Account::LocationsController < Users::AccountsController

  def edit

  end

  def update
    location = Users::Location.new(params[:users_location])
    if location.valid? and current_user.update_attributes(location.attributes, :without_protection => true)
      redirect_to show_user_profile_path(current_user), :notice => 'Location information updated!'
    else
      flash[:error] = 'There was a problem updating your location info...'
      redirect_to show_user_profile_path(current_user, :users_location => location.attributes)
    end
  end
  
end