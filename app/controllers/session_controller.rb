class SessionController < ApplicationController
  def new
    if session[:user].present?
      redirect_to root_url
    end
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
        render :new, status: :unprocessable_entity and return
      elsif @user.authenticate(password)
        session[:user] = @user.name
        session[:role] = @user.role
        session[:user_id] = @user.id
        cookies[:user_name] = { value: @user.name, expires: 14.days.from_now, httponly: true }

        redirect_to root_url, notice: "Welcome back! #{@user.name.capitalize} ♥" 
      else
        flash.now[:alert] = "Email or password is invalid"
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    session[:user] = nil
    session.delete :role
    cookies.delete :user_name
    redirect_to root_url, notice: "See you soon! ♥"
  end
end
