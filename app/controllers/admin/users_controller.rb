module Admin
  class UsersController < UsersController
    
    def index
      @users = User.all
    end
  
    def show
      @user = User.find(params[:id])
    end

    def edit
      @user = User.find(params[:id])
    end

    
    def create
      if params[:user][:role].blank?
        @user = User.new(user_params.merge(role: 'user'))
      else
        @user = User.new(user_params)
      end

      if User.where(email: user_params[:email]).exists?
        @user.errors.add(:email, "The email already exists")
        render :new, status: :unprocessable_entity and return
      elsif @user.save
        after_user_create
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:id])
      @password_update = params[:user][:password_update]

      if @user.update(user_params)
        if @user.password.blank?
          @user.password = @password_update
          @user.save
        end

        after_user_update
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
        redirect_to admin_users_path, notice: "User was successfully created."
      end

      def after_user_update
        redirect_to admin_users_path, notice: "User was successfully updated."
      end
      
      def after_user_delete
        redirect_to admin_users_path, notice: "User was successfully destroyed."
      end

      private
        def user_params
          params.require(:user).permit(:name, :email, :password, :role, :password_update)
        end
  end
end
