class PasswordResetsController < ApplicationController
  before_action :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".success_message"
      redirect_to root_url
    else
      flash.now[:danger] = t ".failure_message"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add :password, t(".empty_password")
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t ".successful_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def valid_user
    @user = User.find_by email: params[:email]
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    flash[:danger] = t ".invalid_link"
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".expired_reset"
    redirect_to new_password_reset_path
  end
end
