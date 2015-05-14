class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new]

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.find_by_credentials(
      params[:user][:user_name],
      params[:user][:password])

    if @user
      login_user!
      redirect_to cats_url
    else
      @user = User.new
      @user.user_name = params[:user][:user_name]
      flash[:errors] = ["Username/Password combination was incorrect."]
      render :new
    end
  end

  def destroy
    current_user.reset_session_token!
    session[:session_token] = nil
    redirect_to cats_url
  end
end
