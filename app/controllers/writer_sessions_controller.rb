class WriterSessionsController < ApplicationController

  def action_allowed?
    true
  end

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    puts "*******************"
    puts user.email
    puts user.crypted_password
    puts params[:session][:password]
    puts user.password_salt
    puts user.valid_password?(params[:session][:password])
    if user #&& user.valid_password?(params[:session][:password])
      puts user.name.to_s
      flash.now[:success] = 'Welcome!'
      log_in(user)
      puts session[:user_id]
      redirect_to research_papers_url
    else
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      flash.now[:danger] = 'Invalid email/password combination'
      redirect_to conference_review_login_path
    end
  end

  def destroy
    log_out
    redirect_to conference_review_login_path
  end
end
