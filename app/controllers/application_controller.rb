class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :user_aunthenticated?
  helper_method :user_admin?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue Mongoid::Errors::DocumentNotFound
    session.delete :user_id
    nil
  end

  def user_aunthenticated?
    !current_user.nil? # Devuelve true ya que no esta vacio
  end

  def user_admin?
    current_user.role == 'admin'
  end

  def is_login
    return redirect_to root_path unless current_user.nil? #si es true el unless no hace nada
  end

  def validate_user
    return redirect_to root_path unless user_aunthenticated?
  end

  def validate_admin
    return redirect_to root_path unless user_aunthenticated? && user_admin?
  end
end
