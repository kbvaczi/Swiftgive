class AccountsController < ApplicationController

  before_filter :authenticate_user!
  
  def show
    set_back_path
  end

  def update
		if current_user.account.update_attributes(params[:account])
			redirect_to show_user_profile_path, :notice => 'Your changes were successfully applied...'
		else
			flash[:error] = 'Error applying your changes...'
			redirect_to show_user_profile_path
		end

  end

 end
