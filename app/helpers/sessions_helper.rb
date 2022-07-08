module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    return if session_authenticate session[:user_id]

    cookie_authenticate cookies.signed[:user_id]
  end

  def session_authenticate user_id
    @current_user || @current_user = User.find_by(id: user_id)
  end

  def cookie_authenticate user_id
    user = User.find_by id: user_id
    return unless user&.authenticated? cookies[:remember_token]

    log_in user
    @current_user = user
  end

  def logged_in?
    current_user.present?
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end
end
