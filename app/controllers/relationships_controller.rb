class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :get_follow_user, only: :create
  before_action :get_unfollow_user, only: :destroy

  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    current_user.unfollow @user
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def get_follow_user
    @user = User.find params[:followed_id]
    return show_error unless @user
  end

  def get_unfollow_user
    @user = Relationship.find(params[:id]).followed
    return show_error unless @user
  end

  def show_error
    flash[:danger] = t "users.not_found"
    redirect_to root_path
  end
end
