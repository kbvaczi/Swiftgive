class Accounts::PaymentCardsController < ApplicationController

  before_filter :authenticate_user!
  
  def create    
    card = current_user.account.payment_cards.build(params[:accounts_payment_card])
    is_card_default = current_user.account.payment_cards.where(:is_default => true).present? ? false : true
    card.is_default = is_card_default
    if card.save
      flash[:notice] = "Payment card added successfully..."
    else
      flash[:error] = 'Error adding payment card...'
    end
    respond_to do |format|
      format.html { redirect_to back_path }
      format.mobile { redirect_to back_path }        
      format.json do
        if card.present? and card.persisted? 
          render :json => card.attributes
        else
          render :json => false
        end
      end
    end
  end
  
  def destroy
    payment_card_to_destroy = current_user.account.payment_cards.where(:id => params[:id]).first
    if payment_card_to_destroy.present? and payment_card_to_destroy.destroy
      redirect_to back_path, :notice => 'Payment card successfully removed...'
    else
      flash[:error] = 'Error removing payment card...'
      redirect_to back_path
    end
  end

end
