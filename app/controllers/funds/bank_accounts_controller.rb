class Funds::BankAccountsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_fund_owner

  def create
    if params[:accountData].present? and params[:accountData][:balanced_uri].present?
      bank_account = current_fund.build_bank_account(params[:accountData])
      if bank_account.save
        redirect_to back_path, :notice => "Bank account added successfully..."
        return
      end
    end    
    flash[:error] = 'Error adding bank account...'
    redirect_to back_path    
  end
  
  def destroy
    bank_account_to_destroy = current_fund.bank_account
    if bank_account_to_destroy.present? and bank_account_to_destroy.destroy
      redirect_to back_path, :notice => 'Bank account successfully removed...'
    else
      flash[:error] = 'Error removing bank account...'
      redirect_to back_path
    end
  end

  protected
  
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