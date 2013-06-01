class PaymentsController < ApplicationController

  def new
    set_back_path
    @payment = Payment.new(params[:payment])
    @payment.fund ||= receiving_fund
    @payment.amount = 500
    respond_to do |format|
      format.html
      format.mobile
    end
  end
  
  def create
    payment = Payment.new(params[:payment])
    if user_signed_in?
      payment.sender = current_user.account
      #TODO: more intelligent way of selecting payment cards for logged in users
      payment.payment_card_used = payment.sender.payment_cards.where(params[:payment_card_used]).first_or_initialize
    else
      #TODO: prevent guests from hyjacking existing users credit cards by stealing balanced uri
      payment_card = Accounts::PaymentCard.new(:balanced_uri => params[:payment_card_used][:balanced_uri])
      account = Account.new
      payment_card.account = account
      payment.payment_card_used = payment_card
      payment.sender = account
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
