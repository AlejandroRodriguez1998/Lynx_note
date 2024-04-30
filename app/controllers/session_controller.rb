class SessionController < ApplicationController
  before_action :is_login, only: [:new]

  def new
  end

  def create
    email = params[:email]
    password = params[:password]

    if email.blank? || password.blank?
      flash.now[:alert] = "Username and password can't be blank"

      @email_error = true if email.blank?
      @password_error = true if password.blank?
      
      render :new, status: :unprocessable_entity and return
    else
      @user = User.where(email: email).first
      if @user.nil?
        flash.now[:alert] = "Email or password is invalid"
        @email_error = true
        @password_error = true
        render :new, status: :unprocessable_entity and return
      elsif @user.authenticate(password)
        session[:user_id] = @user.id
        redirect_to root_url, notice: "Welcome back! #{@user.name.capitalize} ♥" 
      else
        flash.now[:alert] = "Email or password is invalid"
        @email_error = true
        @password_error = true
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    session.delete :user_id
    redirect_to root_url, notice: "See you soon! ♥"
  end
end
