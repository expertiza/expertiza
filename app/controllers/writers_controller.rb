class WritersController < ApplicationController

  def action_allowed?
    true
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role_id = 7
    @user.is_new_user = 1
    if @user.save
      flash[:success] = "Your account has been successfully created"
      render 'new.html.erb'
    else
      render 'new.html.erb'
    end
  end
end
