class NotificationsController < ApplicationController
    before_action :validate_user

    def index
        @notifications = current_user.notifications.all
        render json: @notifications
    end

    def destroy
        @notification = Notification.find(params[:id])
        @notification.destroy
    end

end