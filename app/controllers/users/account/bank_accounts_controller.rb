class Users::Account::BankAccountsController < ApplicationController

  before_filter :authenticate_user!
      
  def create
    begin      
      if params[:accountData].present? and params[:accountData][:is_valid]
        bank_account = current_user.bank_accounts.build(params[:accountData])
        if bank_account.save
          redirect_to back_path, :notice => "Bank account added successfully..."
        else
          throw bank_account.errors
          flash[:error] = 'Error adding bank account...'
          redirect_to back_path
        end
      end
    end
  end
  
  def destroy
    bank_account_to_destroy = current_user.bank_accounts.where(:id => params[:id]).first
    if bank_account_to_destroy.present? and bank_account_to_destroy.destroy
      redirect_to back_path, :notice => 'Bank account successfully removed...'
    else
      flash[:error] = 'Error removing bank account...'
      redirect_to back_path
    end
  end

end