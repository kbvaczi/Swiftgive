class Accounts::LocationsController < AccountsController

  def edit

  end

  def update
    location = Accounts::Location.new(params[:accounts_location])
    if location.valid? and current_user.account.update_attributes(location.attributes, :without_protection => true)
      redirect_to show_user_profile_path, :notice => 'Location information updated!'
    else
      flash[:error] = 'There was a problem updating your location info...'
      redirect_to show_user_profile_path(:accounts_location => location.attributes)
    end
  end
  
end