class HomeController < ApplicationController

  def index    
    set_back_path
    respond_to do |format|
      format.html {render :layout => "full"}
      format.mobile
    end
  end
  
  # serves robots.txt based on environment
  def robots  
    robots = File.read(Rails.root + "public/robots.#{Rails.env}.txt")
    render :text => robots, :layout => false, :content_type => "text/plain"
  end

  def test
    temp_dir = Rails.root.join('tmp')
    Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir) # creates temp directory in heroku, which is not automatically created
    #give_code_image_tempfile = Tempfile.new(["give_code", '.png'], 'tmp', :encoding => 'ascii-8bit')

    first_image = MiniMagick::Image.open("#{Rails.root}/app/assets/images/give_code_wrapper.svg")
    first_image.format :png
    first_image.resize "500x500"
    second_image = MiniMagick::Image.open("#{Rails.root}/app/assets/images/facebook.png")
    result = first_image.composite(second_image) do |c|
      c.compose "Over" # OverCompositeOp
      c.geometry "+20+20" # copy second_image onto first_image from (20, 20)
    end
    first_image.write "#{Rails.root}/tmp/test.png"
    #generated_code_image = IMGKit.new(Rails.application.routes.url_helpers.give_code_html_fund_url(:id => self.uid, :host => ENV['HOST'], :format => :png), :quality => 50, :height => 700, :width => 600, :'disable-smart-width' => true, :zoom => 1).to_img(:png)
  end

end
