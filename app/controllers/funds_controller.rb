class FundsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:show]
  before_filter :verify_creator_info_present, :only => [:new, :create]
  before_filter :authenticate_fund_owner, :only => [:edit, :manage, :toggle_active_status, :update, :destroy]

  # GET /funds
  def index
    set_back_path
    @funds = Fund.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /funds/1
  def show
    set_back_path
    current_fund

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def manage
    set_back_path
    current_fund

    respond_to do |format|
      format.html
    end
  end

  # GET /funds/new
  def new
    @fund = Fund.new(@creator_account.attributes.slice('street_address', 'city', 'state', 'postal_code'))
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /funds/1/edit
  def edit
    current_fund
  end

  # POST /funds
  def create
    @fund = Fund.new(params[:fund])
    @fund.creator = @creator_account
    @fund.creator_info = @creator_info
    if @fund.save
      redirect_to fund_path(@fund), notice: 'Fund was successfully created.'
    else
      flash[:error] = @fund.errors.full_messages.to_s
      render action: "new"
    end    
  end

  # PUT /funds/1
  def update
    current_fund
    respond_to do |format|
      if @fund.update_attributes(params[:fund])
        format.html { redirect_to back_path, notice: 'Fund was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def toggle_active_status
    if current_fund.update_attribute(:is_active, !current_fund.is_active)
      redirect_to back_path, :notice => 'Successfully updated active status...'
    else
      flash[:error] = 'Could not update status...'
      redirect_to back_path
    end
  end

  # DELETE /funds/1
  def destroy
    if current_fund.destroy
      redirect_to root_path, :notice => 'fund deleted'
    else
      flash[:error] = 'fund cound not be deleted'
      redirect_to back_path
    end
  end
  
  protected
  
  def verify_creator_info_present
    @creator_account = current_user.account
    required_attributes = %w(first_name last_name date_of_birth street_address city state postal_code)
    required_attributes.each do |this_attribute|
      unless @creator_account[this_attribute].present?
        flash[:error] = 'Please complete your profile before creating a fund...'
        redirect_to show_user_profile_path
        return
      end
    end    
  end

  def authenticate_fund_owner
    unless current_fund.owners.include? current_user.account
      flash[:error] = 'You are not an owner of this fund...'
      redirect_to back_path 
    end
  end
  
  def current_fund
    @fund ||= Fund.find_by_uid(params[:id])
  end
  helper_method :current_fund
  
end
