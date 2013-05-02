class Funds::GiveCodesController < ApplicationController

  def show

  end

  def give_code_html
    code_url = new_payment_url(:fund_uid => current_fund.uid)
    Rails.logger.info "test"
    Rails.logger.info current_fund
    Rails.logger.info "test"
    Rails.logger.info Fund.find_by_uid(params[:id])
    Rails.logger.info "test"
    Rails.logger.info code_url
    Rails.logger.info "test"

    render :partial => 'funds/give_codes/give_code', :layout => false, :foramts => [:html], :locals => {:message => code_url, :include_header => true}
    return
  end

  def give_code_image
    code_image = IMGKit.new(give_code_html_fund_url(current_fund), :quality => 50, :height => 700, :width => 600, :'disable-smart-width' => true, :zoom => 1).to_img(:png)
    send_data(code_image, :type => 'image/png', :disposition => 'inline')
    return
  end
  
  def current_fund
    @fund ||= Fund.find_by_uid(params[:id])
  end
  helper_method :current_fund

end
