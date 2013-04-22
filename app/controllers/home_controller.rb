class HomeController < ApplicationController

  def index    
    respond_to do |format|
      format.html {render :layout => "full"}
      format.mobile
    end
  end
  
  def robots
    # serves robots.txt based on environment
    robots = File.read(Rails.root + "public/robots.#{Rails.env}.txt")
    render :text => robots, :layout => false, :content_type => "text/plain"
  end
  
  def test

  end
  

  def test2    

  end

end
