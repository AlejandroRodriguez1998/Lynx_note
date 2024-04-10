class UsersController < UsersBaseController
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
end
