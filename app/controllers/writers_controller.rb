class WritersController < ApplicationController
  def action_allowed?
    true
  end

  def new
    @user = User.new
  end

  def create
    if session[:user_id].nil?
      @user = User.new(user_params)
      @user.role_id = 7
      @user.is_new_user = 1
      if @user.save
        flash[:success] = "Your account has been successfully created"
        render 'writer_sessions/new.html.erb'
      else
        render 'new.html.erb'
      end
    else
      @user = User.new(user_params)
      @user.role_id = 7
      @user.is_new_user = 1
      if @user.save
        flash[:success] = "Contributor has been added to your paper" + session[:paper_id].to_s
        @body = 'Login at www.expertiza.ncsu.edu/conference_review/signup' + '\n Name' + @user.name + '\n Email ' + @user.email + 'Login with above details'
        prepared_mail = MailerHelper.send_mail_to_user(@user, "your expertiza account has been created", "user_welcome", @body)
        prepared_mail.deliver
        @paper_writer_map = PaperWriterMapping.new
        @paper_writer_map.writer_id = @user.id
        @paper_writer_map.paper_id = session[:paper_id]
        @paper_writer_map.save
        redirect_to research_papers_url
      else
        render 'new.html.erb'
      end
    end
  end

  def user_params
    params.require(:user).permit(:name,
                                 :crypted_password,
                                 :email)
  end
end
