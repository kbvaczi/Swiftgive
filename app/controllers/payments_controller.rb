class PaymentsController < ApplicationController

  before_filter :set_back_path, :only => [:new]

  def new
    @payment = Payment.new(params[:payment])
    @payment.fund_id ||= receiving_fund.id
    @payment.amount = 500
    respond_to do |format|
      format.html
      format.mobile
    end
  end
  
  def create
    payment = Payment.new(params[:payment])
    building_new_payment_card = params[:payment_card_used].present?
    if building_new_payment_card
      payment.build_payment_card_used(params[:payment_card_used]) 
    elsif user_signed_in?
      payment.payment_card_used = current_user.payment_cards.first
    end
    if payment.save
      redirect_to root_path, :notice => 'Thanks for giving!'
    else
      Rails.logger.debug payment.errors.full_messages
      flash[:error] = 'Error trying to give...'
      redirect_to back_path
    end
  end

  def destroy
  end
  
  protected
  
  def set_redirect_path
    request.session['devise.redirect_path'] = curent_path
  end

  def receiving_fund
    @receiving_fund ||= Fund.find_by_uid(params[:fund_uid])
  end
  helper_method :receiving_fund

end
