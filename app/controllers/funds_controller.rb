class FundsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:show]
  before_filter :authenticate_fund_owner, :only => [:edit, :update, :destroy]

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

  # GET /funds/new
  def new
    @fund = Fund.new

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
    @fund.owners << current_user # creator of fund is automatically an owner
    
    respond_to do |format|
      if @fund.save
        format.html   { redirect_to @fund, notice: 'Fund was successfully created.' }
        format.mobile { redirect_to @fund, notice: 'Fund was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
    return
  end

  # PUT /funds/1
  def update
    current_fund

    respond_to do |format|
      if @fund.update_attributes(params[:fund])
        format.html { redirect_to @fund, notice: 'Fund was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /funds/1
  def destroy
    current_fund
    @fund.destroy

    respond_to do |format|
      format.html { redirect_to funds_url }
    end
  end
  
  protected
  
  def authenticate_fund_owner
    unless current_fund.owners.include? current_user
      flash[:error] = 'You are not an owner of this fund...'
      redirect_to back_path 
    end
  end
  
  def current_fund
    @fund ||= Fund.find_by_uid(params[:id])
  end
  helper_method :current_fund
  
end
