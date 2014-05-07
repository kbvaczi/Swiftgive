class Funds::GiveCodesController < ApplicationController

  def show

  end

  def give_code_html
    code_url = new_payment_url(:fund_uid => current_fund.uid)
    
    case params[:product]
      when 'businesscard'
        render :partial => 'funds/give_codes/business_card', :layout => false, :formats => [:html], :locals => {:message => code_url, :include_header => true}
      else
        render :partial => 'funds/give_codes/give_code', :layout => false, :formats => [:html], :locals => {:message => code_url, :include_header => true}    
    end

    return
  end

  def give_code_image
    #code_url = new_payment_url(:fund_uid => current_fund.uid)
    #code_image_html = render_to_string :partial =>'funds/give_codes/give_code', :locals => {:message => code_url, :width => 1000}
    #code_image = IMGKit.new(code_image_html, :quality => 90, :height => 1200, :width => 1000, :zoom => 1).to_img(:png)
    #send_data(code_image, :type => 'image/png', :disposition => 'inline') 

    code_url = new_payment_url(:fund_uid => current_fund.uid)
    code_image_html = render_to_string :partial =>'funds/give_codes/give_code', :locals => {:message => code_url, :width => 500}
    code_image = PDFKit.new(code_image_html, {:'page-height'    => '5300px', 
                                              :'page-width'     => '5000px', 
                                              :'margin-top'     => '0', 
                                              :'margin-bottom'  => '0',
                                              :'margin-left'    => '0',
                                              :'margin-right'   => '0'}).to_pdf
    send_data(code_image, :type => 'image/pdf', :disposition => 'inline') 
    return
  end
  
  def current_fund
    @fund ||= Fund.find_by_uid(params[:id])
  end
  helper_method :current_fund

end
