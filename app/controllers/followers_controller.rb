class FollowersController < ApplicationController
  before_action :load_user, only: :index

  def index
    @title = t ".title"
    @pagy, @users = pagy @user.followers
    render "users/show_follow"
  end
end
