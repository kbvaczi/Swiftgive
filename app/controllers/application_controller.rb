
class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  # Mobile web functionality (mobylette gem)
  include Mobylette::RespondToMobileRequests  
  mobylette_config do |config|
    config[:skip_xhr_requests] = false # this is needed for jquery mobile framework which sends requests via xhr
  end
  # Uncomment the next line to force all requests to be treated as mobile requests (for testing)
  # before_filter Proc.new { session[:mobylette_override] = :force_mobile }
  
  # Attempts to determines if user is a bot (used so we can not give sessions or cookies to bots, also disallow bots to create accounts)
  def bot_user?
    request.user_agent =~ /\b(NewRelicPinger|Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end
  helper_method :bot_user? 
  
  # sets the current page as the back path for following pages to return to when back_path is redirected to
  def set_back_path
    unless @new_back_path_queue.present?                                                                              # prevents this from breaking if called multiple times during one request
      @current_back_path_queue = session[:back_path] || [root_url]
      @new_back_path_queue    = @current_back_path_queue.dup                                                           # create a copy so the two aren't linked to the same memory address
      if @current_back_path_queue.include?(current_path)                                                               # if we are revisiting an old link in the queue, let's clean up the queue (prevents infinite loops)
        @new_back_path_queue.pop(@new_back_path_queue.length - @new_back_path_queue.index(current_path))              # remove everyting in the queue visited after this link in the queue
      end                                                                 
      @new_back_path_queue.push(current_path)
      @new_back_path_queue.shift if @new_back_path_queue.length > 5                                                   # manage queue size maximum
      session[:back_path] = @new_back_path_queue unless @new_back_path_queue == @current_back_path_queue               # don't hit session again if back path queue hasn't changed
    end
  end
  helper_method :set_back_path  
    
  # returns to the url where set_back_path has last been set and clears back_path
  def back_path
    unless @back_path.present?
      @current_back_path_queue = @new_back_path_queue || session[:back_path] || [root_url]                      
      if @current_back_path_queue.include?(current_path)
        if @current_back_path_queue.length > 1
          @back_path = @current_back_path_queue[@current_back_path_queue.index(current_path) - 1] || root_url  
        else
          @back_path = root_url
        end
      else
        @back_path = @current_back_path_queue.last || root_url
      end
    end
    @back_path
  end
  helper_method :back_path
  
  def current_path(options = {})
    options = request.params.symbolize_keys.merge(options).merge(:format => nil)
    @current_path ||= (url_for Rails.application.routes.recognize_path(request.path).merge(options)) rescue root_path
    #@current_path ||= url_for(params.merge(:authenticity_token => nil, :utf8 => nil, :sort => nil, :sort_order => nil))
  end
  helper_method :current_path

  # Used to create unique page ID for mobile pages
  def current_page_id
    Rails.application.routes.recognize_path(request.path).inspect.parameterize('_') rescue root_path
  end
  helper_method :current_page_id
  
end
