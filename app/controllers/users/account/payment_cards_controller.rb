class Users::Account::PaymentCardsController < ApplicationController

  before_filter :authenticate_user!
  
  def create
    begin      
      if params[:cardData].present? and params[:cardData][:is_valid]
        card_is_default = current_user.payment_cards.present? ? false : true
        card = current_user.payment_cards.build(params[:cardData])        
        card.is_default = card_is_default
        if card.save 
          redirect_to back_path, :notice => "Payment card added successfully..."
        else
          flash[:error] = 'Error adding payment card...'
          redirect_to back_path
        end
      end
    end
  end
  
  def destroy
    payment_card_to_destroy = current_user.payment_cards.where(:id => params[:id]).first
    if payment_card_to_destroy.present? and payment_card_to_destroy.destroy
      redirect_to back_path, :notice => 'Payment card successfully removed...'
    else
      flash[:error] = 'Error removing payment card...'
      redirect_to back_path
    end
  end

end
