class HomeController < ApplicationController

  def index    
    render :layout => "full"
  end
  
  def test
    
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
    

  end

end
