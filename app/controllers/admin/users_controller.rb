module Admin
  class UsersController < UsersBaseController
    
    def index
      @users = User.all
    end
  
    def show
      @user = User.find(params[:id])
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
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
  end
end
