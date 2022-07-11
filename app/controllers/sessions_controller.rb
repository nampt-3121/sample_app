class SessionsController < ApplicationController
  def new; end

  def create
    email, password = params[:session].values_at(:email, :password)
    @user = User.find_by email: email.downcase
    return do_activated if @user&.authenticate password

    flash.now[:danger] = t ".failure_message"
    render :new
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def do_activated
    if @user.activated?
      log_in @user
      params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
      redirect_back_or @user
    else
      flash[:warning] = t ".unactivated_message"
      redirect_to root_url
    end
  end
end
