class UsersController < ApplicationController
  before_action :is_login

  def is_login
    if session[:user].present?
      redirect_to root_url
    end
  end

  def index
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role: 'user'))
  
    if User.where(email: user_params[:email]).exists?
      @user.errors.add(:email, "The email already exists")
      render :new, status: :unprocessable_entity and return
    elsif @user.save
      after_user_create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  protected
    def after_user_create
      redirect_to root_url, notice: "Registered, you can now log in"
    end

    def after_user_update
      redirect_to root_url, notice: "User was successfully updated."
    end
    
    def after_user_delete
      redirect_to root_url, notice: "User was successfully destroyed."
    end

  private
  def user_params
      params.require(:user).permit(:name, :email, :password, :role)
  end
end
