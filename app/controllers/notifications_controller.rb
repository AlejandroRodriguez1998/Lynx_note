class NotificationsController < ApplicationController
    before_action :validate_user

    def index
        @notifications = current_user.notifications.all
        render json: @notifications
    end
end