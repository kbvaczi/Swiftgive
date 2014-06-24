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

  def terms
    set_back_path
    respond_to do |format|
      format.html {render :layout => "full"}
      format.mobile
    end
  end

  def privacy
    set_back_path
    respond_to do |format|
      format.html {render :layout => "full"}
      format.mobile
    end
  end

  def about
    set_back_path
    respond_to do |format|
      format.html {render :layout => "full"}
      format.mobile
    end
  end


  # used for testing.  This should be empty when pushed.
  def test

  end

end
