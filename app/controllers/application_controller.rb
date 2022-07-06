class ApplicationController < ActionController::Base
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
end
