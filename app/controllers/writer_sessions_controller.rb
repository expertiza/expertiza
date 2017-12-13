class WriterSessionsController < ApplicationController
  def action_allowed?
    true
  end

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user
      flash.now[:success] = 'Welcome!'
      log_in(user)
      redirect_to research_papers_url
    else
      flash.now[:danger] = 'Invalid email/password combination'
      redirect_to conference_review_login_path
    end
  end

  def destroy
    log_out
    redirect_to conference_review_login_path
  end
end
