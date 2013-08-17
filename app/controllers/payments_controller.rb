class PaymentsController < ApplicationController

  before_filter :verify_fund_present, :only => [:new]
  before_filter :set_back_path, :only => [:new]  
  before_filter :set_referring_fund_and_redirect_to_splash, :only => [:new]

  def guest_splash
    render :layout => 'full'
  end

  def new
    @payment = Payment.new(params[:payment])
    @payment.fund ||= receiving_fund
    @payment.amount_in_cents = 500
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
      payment_card = Accounts::PaymentCard.new(:balanced_uri => params[:payment_card_used][:balanced_uri])
      payment_card.validate_card_with_balanced
      Balanced::Card.where(:hash => payment_card.balanced_hash).each do |duplicate_balanced_card|
        duplicate_card = Accounts::PaymentCard.where(:balanced_uri => duplicate_balanced_card.uri)
        if duplicate_card.present? and duplicate_card.account.user_id.nil?
          duplicate_card_without_user = duplicate_card 
          break
        end
      end
      account = defined?(duplicate_card_without_user) ? duplicate_card_without_user.account : Account.new
      payment_card.account = account
      payment.payment_card_used = payment_card
      payment.sender = account
    end
    if payment.save
      payment_card.invalidate unless user_signed_in?
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

  def receiving_fund
    @receiving_fund ||= Fund.find_by_uid(params[:fund_uid])
  end
  helper_method :receiving_fund

  def verify_fund_present
    unless receiving_fund.present?
      flash[:error] = 'This fund does not exist...'
      redirect_to back_path
    end
  end

  def set_referring_fund_and_redirect_to_splash
    session[:referring_fund_uid] = receiving_fund.uid
    unless !is_mobile_request? or user_signed_in? or params[:guest_payment].present?
      redirect_to guest_splash_path
    end
  end

end
