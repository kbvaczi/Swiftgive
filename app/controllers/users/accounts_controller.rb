class Users::AccountsController < ApplicationController

  before_filter :authenticate_user!
  
  def show
    set_back_path
  end

 end
