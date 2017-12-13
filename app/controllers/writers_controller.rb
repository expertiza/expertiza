class WritersController < ApplicationController
  before_action :create_writer, only: [:create]

  def action_allowed?
    true
  end

  def new
    @user = User.new
  end

  def create
    create_writer
    if @user.save && session[:user_id].nil?
      flash[:success] = "Your account has been successfully created"
      render 'writer_sessions/new.html.erb'
    elsif @user.save
      flash[:success] = "Contributor has been added to your paper" + session[:paper_id].to_s
      send_mail
      paper_writer_mapping
      redirect_to research_papers_url
    else
      render 'new.html.erb'
    end
  end

  def create_writer
    @user = User.new do |user|
      user.assign_attributes(user_params)
      user.role_id = 7
      user.is_new_user = 1
    end
  end

  def paper_writer_mapping
    @paper_writer_map = PaperWriterMapping.new do |map|
      map.writer_id = @user.id
      map.paper_id = session[:paper_id]
    end
    @paper_writer_map.save
  end

  def send_mail
    @body = 'Login at www.expertiza.ncsu.edu/conference_review/signup' + '\n Name' + @user.name + '\n Email ' + @user.email + 'Login with above details'
    prepared_mail = MailerHelper.send_mail_to_user(@user, "your expertiza account has been created", "user_welcome", @body)
    prepared_mail.deliver
  end

  def user_params
    params.require(:user).permit(:name,
                                 :crypted_password,
                                 :email)
  end
end
