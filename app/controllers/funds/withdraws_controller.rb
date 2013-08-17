class Funds::WithdrawsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_fund_owner
  before_filter :verify_bank_account_present

  def create
    withdraw = Funds::Withdraw.new({:fund_id => current_fund.id, :bank_account_id => current_fund.bank_account.id}, :without_protection => true)
    if withdraw.save
      redirect_to back_path, :notice => "Your withdraw is being processed..."
    else 
      flash[:error] = 'Error creating withdraw...'
      redirect_to back_path    
    end
  end

  protected
  
  def verify_bank_account_present
    unless current_fund.bank_account.present?
      flash[:error] = 'You must link your fund to a bank account to withdraw your balance...'
      redirect_to back_path
    end
  end

  def authenticate_fund_owner
    unless current_fund.owners.include? current_user.account
      flash[:error] = 'You are not an owner of this fund...'
      redirect_to back_path 
    end
  end

  def current_fund
    @fund ||= Fund.find_by_uid(params[:fund_id])
  end
  helper_method :current_fund

end