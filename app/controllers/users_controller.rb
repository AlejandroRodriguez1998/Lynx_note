class UsersController < ApplicationController
  before_action :is_login, only: [:new]
  before_action :validate_user, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to root_url
  end

  def show
    @user = User.find(current_user.id)
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
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])
    user_email = user_params[:email]

  
    if user_params[:password].blank?
      @user.password_update = @user.password
    end
    
    if user_email != @user.email
      if User.where(email: user_params[:email]).exists?
        @user.errors.add(:email, "The email already exists")
        render :edit, status: :unprocessable_entity and return
      end
    end

    if @user.update(user_params)
      if @user.password.blank?
        @user.password = @user.password_update
        @user.save
      end

      after_user_update(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    after_user_delete
  end

  protected
    def after_user_create
      redirect_to root_url, notice: "Registered, you can now log in"
    end

    def after_user_update(user)
      redirect_to user, notice: "User was successfully updated."
    end
    
    def after_user_delete
      session.delete(:user_id)
      head :no_content
    end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :password_update)
  end
end
