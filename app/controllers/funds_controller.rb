class FundsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:show]
  before_filter :authenticate_fund_owner, :only => [:edit, :update, :destroy]

  # GET /funds
  # GET /funds.json
  def index
    set_back_path
    @funds = Fund.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @funds }
    end
  end

  # GET /funds/1
  # GET /funds/1.json
  def show
    set_back_path
    @fund = Fund.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fund }
    end
  end

  # GET /funds/new
  # GET /funds/new.json
  def new
    @fund = Fund.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fund }
    end
  end

  # GET /funds/1/edit
  def edit
    @fund = Fund.find(params[:id])
  end

  # POST /funds
  # POST /funds.json
  def create
    @fund = Fund.new(params[:fund])
    @fund.owners << current_user # creator of fund is automatically an owner
    
    respond_to do |format|
      if @fund.save
        format.html { redirect_to @fund, notice: 'Fund was successfully created.' }
        format.json { render json: @fund, status: :created, location: @fund }
      else
        format.html { render action: "new" }
        format.json { render json: @fund.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /funds/1
  # PUT /funds/1.json
  def update
    @fund = Fund.find(params[:id])

    respond_to do |format|
      if @fund.update_attributes(params[:fund])
        format.html { redirect_to @fund, notice: 'Fund was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fund.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /funds/1
  # DELETE /funds/1.json
  def destroy
    @fund = Fund.find(params[:id])
    @fund.destroy

    respond_to do |format|
      format.html { redirect_to funds_url }
      format.json { head :no_content }
    end
  end
  
  def give_code
    code_url = new_payment_url(:fund_uid => current_fund.uid)
    render :partial => 'funds/give_code', :locals => {:message => code_url}    
  end
  
  protected
  
  def authenticate_fund_owner
    unless current_fund.owners.include? current_user
      flash[:error] = 'You are not an owner of this fund...'
      redirect_to back_path 
    end
  end
  
  def current_fund
    @fund ||= Fund.find(params[:id])
  end
  helper_method :current_fund
  
end
