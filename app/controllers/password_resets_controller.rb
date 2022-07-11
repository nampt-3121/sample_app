class PasswordResetsController < ApplicationController
  before_action :valid_user, :check_expiration, only: %i(edit update)
  before_action :check_empty_password, only: :update

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
    if @user.update(user_params)
      log_in @user
      flash[:success] = t ".successful_reset"
      redirect_to @user
    else
      flash[:danger] = t ".something_wrong"
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

  def check_empty_password
    return if params[:user][:password].present?

    @user.errors.add :password, t(".empty_password")
    render :edit
  end
end
