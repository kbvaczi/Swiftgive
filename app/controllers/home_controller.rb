class HomeController < ApplicationController

  def index    
    render :layout => "full"
  end
  
  def test
    params_to_send_to_stripe = {:email => current_user.email, 
                                :url => 'http://localhost:3000', # profile page on swiftgive
                                :first_name => current_user.first_name,
                                :last_name => current_user.last_name,
                                :physical_product => false,
                                :average_payment => 2,
                                :country => current_user.country == 'CA' ? 'CA': 'US',
                                :currency => current_user.country == 'CA' ? 'cad': 'usd',
                                :business_name => 'test'
                                }
    redirect_to user_omniauth_authorize_path(:stripe_connect, :stripe_user => params_to_send_to_stripe)
    return
    # Amount in cents
    amount = 500

    if params[:stripeToken].present?
      customer = Stripe::Customer.create(
        :email => current_user.email,
        :card  => params[:stripeToken],
        :description => "#{current_user.first_name} #{current_user.last_name} (UserID:#{current_user.id})"        
      )

      current_user.payment_cards.create(:description => 'test_card', :stripe_customer_id => customer.id)
    end

    if current_user.payment_cards.first.present?
      customer_id = current_user.payment_cards.first.stripe_customer_id
      charge = Stripe::Charge.create(
        :customer    => customer_id,
        :amount      => amount,
        :description => 'Rails Stripe customer',
        :currency    => 'usd'
      )
    end
    
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end
  
  def test2
    
    require "uri"
    require "net/http"
    
    uri = URI.parse("https://connect.stripe.com/oauth/token")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({:client_secret => ENV['STRIPE_SECRET_KEY'],
                           :code          => params[:code],
                           :grant_type    => 'authorization_code'})
    response = http.request(request)  
    blah = YAML.load response.body
    throw blah
  end

end
