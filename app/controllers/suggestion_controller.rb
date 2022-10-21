class SuggestionController < ApplicationController
  include AuthorizationHelper

  #This method determines if the action the user makes, is allowed or not 
  #depending on the criteraa that the user has student privileges or TA privileges
  def action_allowed?
    case params[:action]
    when 'create', 'new', 'student_view', 'student_edit', 'update_suggestion', 'submit'
      current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end


  #will allow user to add comment to the suggestion
  def add_comment
    @suggestion_comment = SuggestionComment.new(vote: params[:suggestion_comment][:vote], comments: params[:suggestion_comment][:comments])
    @suggestion_comment.suggestion_id = params[:id]
    @suggestion_comment.commenter = session[:user].name
    if @suggestion_comment.save
      flash[:notice] = 'Your comment has been successfully added.'
    else
      flash[:error] = 'There was an error in adding your comment.'
    end
    if current_user_has_student_privileges?
      redirect_to action: 'student_view', id: params[:id]
    else
      redirect_to action: 'show', id: params[:id]
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }


  #will get the list of suggestions 
  def list
    @suggestions = Suggestion.where(assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  #will get the suggestion for the student_view file
  def student_view
    @suggestion = Suggestion.find(params[:id])
  end

 #will get the suggestion made by user in student_edit file
  def student_edit
    @suggestion = Suggestion.find(params[:id])
  end

 #will get the suggestion, to the show file 
  def show
    @suggestion = Suggestion.find(params[:id])
  end

  #will get suggestion data  to update 
  def update_suggestion
    Suggestion.find(params[:id]).update_attributes(title: params[:suggestion][:title],
                                                   description: params[:suggestion][:description],
                                                   signup_preference: params[:suggestion][:signup_preference])
    redirect_to action: 'new', id: Suggestion.find(params[:id]).assignment_id
  end

  #will get the suggestions data to display in 'new' file
  def new
    @suggestion = Suggestion.new
    session[:assignment_id] = params[:id]
    @suggestions = Suggestion.where(unityID: session[:user].name, assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  #will create a new suggestion and save for the assignment
  def create
    @suggestion = Suggestion.new(suggestion_params)
    @suggestion.assignment_id = session[:assignment_id]
    @assignment = Assignment.find(session[:assignment_id])
    @suggestion.status = 'Initiated'
    @suggestion.unityID = if params[:suggestion_anonymous].nil?
                            session[:user].name
                          else
                            ''
                          end

    if @suggestion.save
      flash[:success] = 'Thank you for your suggestion!' unless @suggestion.unityID.empty?
      flash[:success] = 'You have submitted an anonymous suggestion. It will not show in the suggested topic table below.' if @suggestion.unityID.empty?
    end
    redirect_to action: 'new', id: @suggestion.assignment_id
  end

  #will submit the vote for a particular suggestion
  def submit
    if !params[:add_comment].nil?
      add_comment
    elsif !params[:approve_suggestion].nil?
      # Approve the suggestion and notify the team
      approve_suggestion_and_notify
    elsif !params[:reject_suggestion].nil?
      reject_suggestion
    end
  end

  #will provie notification/email based on the suggestion being approved or not
  #will create and assign team if user is not in any team
  def notification
    if @suggestion.signup_preference == 'Y' and @team_id.nil?
      new_team = AssignmentTeam.create(name: 'Team_' + rand(10_000).to_s,
                                        parent_id: @signuptopic.assignment_id, type: 'AssignmentTeam')
      new_team.create_new_team(@user_id, @signuptopic)
    elsif @suggestion.signup_preference == 'Y' and !@team_id.nil? and @topic_id.nil?
      # clean waitlists
      SignedUpTeam.where(team_id: @team_id, is_waitlisted: 1).destroy_all
      SignedUpTeam.create(topic_id: @signuptopic.id, team_id: @team_id, is_waitlisted: 0)
    elsif @suggestion.signup_preference == 'Y' and !@team_id.nil? and !@topic_id.nil?
      @signuptopic.private_to = @user_id
      @signuptopic.save
      # if this team has topic, Expertiza will send an email (suggested_topic_approved_message) to this team
      Mailer.notify_suggestion_approval(@used_id, @team_id, @suggestion.title)
    else
      # if this team has topic, Expertiza will send an email (suggested_topic_approved_message) to this team
      Mailer.notify_suggestion_approval(@used_id, @team_id, @suggestion.title)
    end
  end

  # Approve the suggestion and notify the team via email.
  def approve_suggestion_and_notify
    approve_suggestion
    notification
    redirect_to action: 'show', id: @suggestion
  end

  #will get  the suggestion to reject
  #if the status is updated to reject-> suggestionn rejected
  #else-> error
  def reject_suggestion
    @suggestion = Suggestion.find(params[:id])
    if @suggestion.update_attribute('status', 'Rejected')
      flash[:notice] = 'The suggestion has been successfully rejected.'
    else
      flash[:error] = 'An error occurred when rejecting the suggestion.'
    end
    redirect_to action: 'show', id: @suggestion
  end

  private

  #will retrieve parameters
  def suggestion_params
    params.require(:suggestion).permit(:assignment_id, :title, :description,
                                       :status, :unityID, :signup_preference)
  end

  #will approve suggestion base  on 
  #if signup  topic -> suggestion approved
  #else-> error
  def approve_suggestion
    @suggestion = Suggestion.find(params[:id])
    @user_id = User.find_by(name: @suggestion.unityID).try(:id)
    if @user_id
      @team_id = TeamsUser.team_id(@suggestion.assignment_id, @user_id)
      @topic_id = SignedUpTeam.topic_id(@suggestion.assignment_id, @user_id)
    end
    # After getting topic from user/team, get the suggestion
    @signuptopic = SignUpTopic.new_topic_from_suggestion(@suggestion)
    # Get success only if the signuptopic object was returned from its class
    if @signuptopic != 'failed'
      flash[:success] = 'The suggestion was successfully approved.'
    else
      flash[:error] = 'An error occurred when approving the suggestion.'
    end
  end
end
