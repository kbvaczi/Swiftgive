class PaymentsController < ApplicationController

  before_filter :verify_fund_present, :only => [:new]
  before_filter :set_back_path, :only => [:new]  
  before_filter :set_referring_fund_and_redirect_to_splash, :only => [:new], :unless => Proc.new { user_signed_in? }

  def new
    @payment = Payment.new(params[:payment])
    @payment.fund ||= receiving_fund
    @payment.amount_in_dollars = 5
    @payment.amount_in_cents = 500
    respond_to do |format|
      format.html
      format.mobile
    end
  end
  
  def create
    payment = Payment.new(params[:payment])
    payment.sender = current_user.account if user_signed_in?
    payment.receiver_email = payment.fund.is_business_fund? ? payment.fund.business_email : payment.fund.creator.user.email
    if payment.save
      respond_to do |format|        
        #format.mobile  { render json: ("[{name:uid, value:" + payment.uid + "}, {name:receiver_email, value:" + payment.receiver_email + "}]").to_json }
        format.mobile  { render json: {:uid => payment.uid, :receiver_email => payment.receiver_email}.to_json }
        #format.html   { redirect_to fund_path(payment.fund), :notice => 'We appreciate your generosity!' }
        #format.mobile { redirect_to payment_path(payment), :notice => 'We appreciate your generosity!' }        
      end
    else
      respond_to do |format|
        format.mobile { render json: "error".to_json }
        #format.html or format.mobile do
        #  flash[:error] = 'Error trying to give...'
        #  redirect_to back_path
        #end        
      end     
    end
  end

  def show
    if user_signed_in?
      @payment = current_user.account.payments.where(:uid => params[:id]).first
    else
      @payment = Payment.where(:uid => params[:id]).where("updated_at > '#{30.minutes.ago}'").first
    end
    unless @payment.present?
      flash[:error] = 'Error viewing payment...'
      redirect_to back_path 
    end
  end

  def guest_splash
    render :layout => 'full'
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
