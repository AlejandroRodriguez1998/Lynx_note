class SessionController < ApplicationController
  def new
  end

  def create
    username = params[:name]
    password = params[:password]

    if username.blank? || password.blank?
      flash.now[:alert] = "Username and password can't be blank"

      @username_error = true if username.blank?
      @password_error = true if password.blank?
      
      render :new, status: :unprocessable_entity
    else
      @user = User.where(name: username).first
      if @user.nil?
        flash.now[:alert] = "Username '#{username.capitalize}' was invalid"
        render :new, status: :unprocessable_entity
      elsif @user.password == Base64.encode64(password)
        session[:user] = @user.name
        session[:role] = @user.role
        cookies[:user_name] = { value: @user.name, expires: 14.days.from_now, httponly: true }

        redirect_to root_url, notice: "Welcome back! #{@user.name.capitalize} ♥" 
      else
        flash.now[:alert] = "The password is invalid"
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    session.delete :user
    session.delete :role
    cookies.delete :user_name
    redirect_to root_url, notice: "See you soon! ♥"
  end
end
