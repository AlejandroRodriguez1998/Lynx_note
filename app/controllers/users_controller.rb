class UsersController < ApplicationController
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
      redirect_to root_url, notice: "Registered, you can now log in"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

end
