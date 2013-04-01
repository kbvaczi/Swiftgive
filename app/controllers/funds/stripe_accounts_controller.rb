class Funds::StripeAccountsController < FundsController

  before_filter :authenticate_user!
  before_filter :authenticate_fund_owner
  before_filter :verify_no_funding_account_present, :only => [:new, :create]
  
  def new
    params_to_send_to_stripe = {:email => current_user.email,
                                :url => fund_url(current_fund), # profile page on swiftgive
                                :first_name => current_user.first_name,
                                :last_name => current_user.last_name,
                                :physical_product => false,
                                :average_payment => 2,
                                :country => current_user.country == 'CA' ? 'CA': 'US',
                                :currency => current_user.country == 'CA' ? 'cad': 'usd',
                                :business_name => current_fund.name }
    redirect_to user_omniauth_authorize_path(:stripe_connect, :stripe_user => params_to_send_to_stripe, :state => current_fund.uid)
  end
  
  def create
    is_authorization_accepted = params[:code].present?
    if is_authorization_accepted
      access_token = params[:code]
      stripe_access_request_response = request_stripe_access(access_token)
      if current_fund.create_stripe_account(:stripe_access_token => stripe_access_request_response['access_token'],
                                            :stripe_refresh_token => stripe_access_request_response['refresh_token'],
                                            :stripe_publishable_key => stripe_access_request_response['stripe_publishable_key'],
                                            :stripe_user_id => stripe_access_request_response['stripe_user_id'],
                                            :stripe_access_response => stripe_access_request_response)
        redirect_to back_path, :notice => 'Funding Account Created'    
        return
      end
    end
    flash[:error] = 'We did not receive authorization to use your funding account...'
    redirect_to back_path
  end

  def destroy
    if current_fund.stripe_account.destroy
      redirect_to back_path, :notice => 'Funding account deleted'
    else
      flash[:error] = 'Problem deleting funding account...'
      redirect_to back_path      
    end
  end
  
  protected

  def verify_no_funding_account_present
    if current_fund.stripe_account.present?
      flash[:error] = 'This fund already has a funding account...'
      redirect_to back_path
    end
  end
  
  def request_stripe_access(access_token)
    #require "uri"
    #require "net/http"
    uri = URI.parse("https://connect.stripe.com/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({:client_secret => ENV['STRIPE_SECRET_KEY'],
                           :code          => access_token,
                           :grant_type    => 'authorization_code'})
    response_body = http.request(request).body
    response = JSON.parse response_body    
  end
  
  def current_fund
    if params[:state].present?
      @fund ||= Fund.find_by_uid(params[:state])
    else
      @fund ||= Fund.find(params[:fund_id])  
    end
  end
  helper_method :current_fund

end
