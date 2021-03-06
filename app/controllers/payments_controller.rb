class PaymentsController < ApplicationController

  before_filter :verify_fund_present, :only => [:new]
  before_filter :set_back_path, :only => [:new]  
  before_filter :set_referring_fund_and_redirect_to_splash, :only => [:new], :unless => Proc.new { user_signed_in? }

  def new
    add_fund_to_recent_funds_viewed
    @payment = Payment.new(params[:payment])
    @payment.fund ||= current_fund
    @payment.amount_in_dollars = 5
    @payment.amount_in_cents = 500
    respond_to do |format|
      format.mobile
    end
  end
  
  def create
    payment = Payment.new(params[:payment])
    payment.sender = current_user if user_signed_in?
    payment.receiver_email = payment.fund.receiver_email.present? ? payment.fund.receiver_email : payment.fund.creator.email
    payment.is_confirmed_by_email = false
    if payment.save
      respond_to do |format|        
        format.mobile  { render json: {:uid => payment.uid, :receiver_email => "#{payment.fund.name} <#{payment.receiver_email}>"}.to_json }
      end
    else
      respond_to do |format|
        format.mobile  { render json: "error".to_json }
      end     
    end
  end

  def show
    @payment = Payment.where(:uid => params[:id]).first
    unless @payment.present?
      flash[:error] = 'Error viewing payment...'
      redirect_to back_path
    end
  end

  def guest_splash
    render :layout => 'full'
  end
  
  protected

  def current_fund
    @current_fund ||= Fund.find_by_uid(params[:fund_uid])
  end
  helper_method :current_fund

  def verify_fund_present
    unless current_fund.present?
      flash[:error] = 'This fund does not exist...'
      redirect_to back_path
    end
  end

  def set_referring_fund_and_redirect_to_splash    
    unless !is_mobile_request? or user_signed_in? or session[:referring_fund_uid]
      redirect_to guest_splash_path
    end
    session[:referring_fund_uid] = current_fund.uid
  end

end
