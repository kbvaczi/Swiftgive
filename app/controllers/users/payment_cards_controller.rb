class Users::PaymentCardsController < ApplicationController

  before_filter :authenticate_user!
  
  def create
    begin      
      if params[:stripeToken].present?
        if current_user.payment_card.nil?
          customer = Stripe::Customer.create(:email => current_user.email, 
                                             :card  => params[:stripeToken],
                                             :description => "#{current_user.first_name} #{current_user.last_name} (UserID:#{current_user.id}) - #{params[:description]}")
                                   
          if current_user.create_payment_card( :stripe_customer_id => customer.id,
                                               :stripe_customer_object => customer.to_yaml )
            redirect_to back_path, :notice => "Payment card added successfully..."
          else
            flash[:error] = 'Error adding payment card...'
            redirect_to back_path
          end
        else
          flash[:error] = 'This account already has a payment card...'
          redirect_to back_path
        end
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to charges_path
    end
  end
  
  def destroy
    payment_card_to_destroy = current_user.payment_card
    if payment_card_to_destroy.present? and payment_card_to_destroy.destroy
      redirect_to back_path, :notice => 'Payment card successfully removed...'
    else
      flash[:error] = 'Error removing payment card...'
      redirect_to back_path
    end
  end

end
