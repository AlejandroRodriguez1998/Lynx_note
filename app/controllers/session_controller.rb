class SessionController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(name: params[:name])
    if !@user
      flash.now.alert = "Username #{params[:name]} was invalid"
      render :new
    elsif @user.password == params[:password]
      session[:user] = @user.name
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now.alert = "The password is invalid"
      render :new
    end
  end

  def destroy
    session[:user] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
