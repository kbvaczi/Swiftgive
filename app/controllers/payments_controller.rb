class PaymentsController < ApplicationController

  before_filter :set_back_path, :only => [:new]
  before_filter :authenticate_user!

  def new
    @payment = Payment.new(params[:payment])
    @payment.fund_id ||= receiving_fund.id
    @payment.amount = 500
    respond_to do |format|
      format.html { }
      format.mobile { }
    end
  end
  
  def create
    payment = Payment.new(params[:payment])
    payment.sender_id = current_user.id
    if payment.save
      redirect_to root_path, :notice => 'Thanks for giving!'
    else
      flash[:error] = 'Error trying to give...'
      redirect_to back_path
    end
  end

  def destroy
  end
  
  protected
  
  def receiving_fund
    @receiving_fund ||= Fund.find_by_uid(params[:fund_uid])
  end
  helper_method :receiving_fund

end
