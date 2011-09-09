# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :set_locale 

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  #before_filter :login_from_cookie
  
  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include SimpleCaptcha::ControllerHelpers   
  
  def generateHashCode(timestamp,paramValues)
    return (Digest::SHA2.new << "#{paramValues}#{timestamp}#{DEHEMS::API_SECRET}").to_s
  end
  
  def random_string(length)
    # Generates a random string consisting of strings and digits (used for resetting passwords)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    new_str = ""
    1.upto(length) { |i| new_str << chars[rand(chars.size-1)]}
    return new_str
  end
  
  def logout_required
    # Should not have access to this page if user is logged in
    # e.g. User cannot login if already logged in
    if logged_in?
      flash[:error] = "The page you are trying to access is unavailable."
      redirect_back_or_default(root_url)
    end
  end
  
   def admin_required
    # Should not have access to this page if user is logged in
    # e.g. User cannot login if already logged in
    if !logged_in?
      redirect_to :controller => "users", :action => "login"
    elsif current_user.is_admin != 1 
      flash[:error] = "You need to be an administrator in order to access the page requested."
      redirect_back_or_default(root_url)
    end
  end
  
  def set_locale 
    if not params[:locale].blank? and not params[:locale].nil?
        I18n.locale = params[:locale]
        session[:locale] = params[:locale]
    elsif session[:locale]
        I18n.locale = session[:locale]
    end  
  end 
  
end
