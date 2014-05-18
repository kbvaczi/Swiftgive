class Funds::GiveCodesController < ApplicationController

  def show

  end

  def give_code_html
    code_url = new_payment_url(:fund_uid => current_fund.uid)
    render :partial => 'funds/give_codes/give_code', :layout => false, :formats => [:html], :locals => {:message => code_url, :include_header => false }
    return
  end

  def give_code_image    
    respond_to do |format|
      format.png do
        code_image = current_fund.give_code_as_png
        send_data(code_image, :type => 'image/png', :disposition => 'inline')
      end
      format.pdf do
        code_image = current_fund.give_code_as_pdf
        send_data(code_image, :type => 'image/pdf', :disposition => 'inline')
      end
    end    
  end
  
  def current_fund
    @fund ||= Fund.find_by_uid(params[:id])
  end
  helper_method :current_fund

end
