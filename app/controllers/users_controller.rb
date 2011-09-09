class UsersController < ApplicationController
  
  before_filter :login_required, :except => [:login, :signup, :reset_password]
  before_filter :logout_required, :only => [:login, :signup, :reset_password]
  
  layout "admin"

  def login
    @title = t(:users__title__login)
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    session[:user] = self.current_user
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_to :controller => "administration"
    else
      @errors = t(:users__error__username_or_password)
    end
  end

  def signup
    @title = t(:users__title__register)
    @user = User.new(params[:user])
    return unless request.post?
    if simple_captcha_valid?
      @user.save!
      self.current_user = @user
      redirect_to user_url(@user.login)
      flash[:notice] = t(:users__notice__welcome)
    else
      errorMsg = t(:users__error__captcha)
      @user.errors.add("captcha", errorMsg)
      render signup_users_url
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    session[:user] = nil
    session[:return_to] = nil
    flash[:notice] = t(:users__notice__logged_out)
    redirect_back_or_default(login_users_url)
  end
  
  def show    
    @title = t(:users__title__my_details)
    store_location
    @user = self.current_user
    @date_of_birth = "#{@user.dob.day} #{Date::MONTHNAMES[@user.dob.month]} #{@user.dob.year}"
  end
  
  def edit_user
    @title = t(:users__title__edit_my_details)
    store_location
    @user = self.current_user
    return unless request.post?
    @user.email = params[:email]
    if @user.update_attributes(params[:user])
      flash[:notice] = t(:users__notice__details_updated)
      redirect_to user_url(@user.login)
    end
  end
  
  def change_location
    @title = t(:users__title__change_location)
    store_location
    @user = self.current_user
    return unless request.post?
    @user.latitude = params[:latitude]
    @user.longitude = params[:longitude]
    if @user.update_attributes(params[:user])
      flash[:notice] = t(:users__notice__location_changed)
      redirect_to user_url(@user.login)
    end
  end
  
  def change_password
    @title = t(:users__title__change_password)
    store_location
    return unless request.post?
    @user = self.current_user
    validate_old_password = User.authenticate(@user.login, params[:old_password])
    if validate_old_password.nil?
      # Old password incorrect
      @errors = t(:users__error__current_password_incorrect)
    else
      if params[:new_password].blank?
        # New password missing
        @errors = t(:users__error__new_password_missing)
      elsif params[:new_password_confirmation].blank?
        # New password confirmation missing
        @errors = t(:users__error__password_confirmation_missing)
      elsif params[:new_password] == params[:new_password_confirmation]
        # Password Confirmation OK
        if @user.update_attribute(:password, params[:new_password])
          # Password Successfully Changed
          flash[:notice] = t(:users__notice__password_updated)
          redirect_to user_url(self.current_user.login)
        else
          flash[:error] = t(:users__error__password_not_changed)
          redirect_to change_password_users_url
        end
      else
        # Error with confirmation
        @errors = t(:users__error__password_confirmation_not_match)
      end
    end
  end
  
  def reset_password
    @title = t(:users__title__reset_password)
    return unless request.post?
    # Find user
    @user = User.find_by_login_and_email(params[:login], params[:email])
    if @user.nil?
      # User not found
      @errors = t(:users__error__username_or_email)
    else
      if simple_captcha_valid?
        # Create new password
        @new_password = random_string(11)
        # Update password in database
        @user.password = @new_password
        @user.password_confirmation = @new_password
        #print "FOR TESTING ONLY: NEW PASSWORD = #{@new_password}\n"
        if @user.update_attributes(params[:user])
          # Email password to user
          PasswordMailer.deliver_reset_password(@user.email, @new_password, Time.now)
          return if request.xhr?
          flash[:notice] = t(:users__notice__password_reset)
          redirect_to login_users_url
        else
          flash[:error] = t(:users__error__password_reset)
          redirect_to reset_password_users_url
        end
      else
        @errors = t(:users__error__captcha)
      end
    end
  end

end
