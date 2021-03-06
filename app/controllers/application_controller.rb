class ApplicationController < ActionController::Base
  include Pagy::Backend

  include SessionsHelper

  before_action :set_locale
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def record_not_found
    flash[:danger] = t "unavaiable_data"
    redirect_to root_path
  end

  def logged_in_user
    return if logged_in?

    flash[:danger] = t ".not_logged"
    store_location
    redirect_to login_path
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".not_found"
    redirect_to root_path
  end
end
