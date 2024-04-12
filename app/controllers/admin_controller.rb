class AdminController < ApplicationController

    def index
        if session[:role] != "admin" && session[:user].present?
            redirect_to root_url 
        end
    end
end