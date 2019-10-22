class SuggestionController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'create', 'new', 'student_view', 'student_edit', 'update_suggestion'
      current_role_name.eql? 'Student'
    when 'submit'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  def add_comment
    @suggestioncomment = SuggestionComment.new(vote: params[:suggestion_comment][:vote], comments: params[:suggestion_comment][:comments])
    @suggestioncomment.suggestion_id = params[:id]
    @suggestioncomment.commenter = session[:user].name
    if @suggestioncomment.save
      flash[:notice] = "Your comment has been successfully added."
    else
      flash[:error] = "There was an error in adding your comment."
    end
    if current_role_name.eql? 'Student'
      redirect_to action: "student_view", id: params[:id]
    else
      redirect_to action: "show", id: params[:id]
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: {action: :list}

  def list
    @suggestions = Suggestion.where(assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  def student_view
    @suggestion = Suggestion.find(params[:id])
  end

  def student_edit
    @suggestion = Suggestion.find(params[:id])
  end

  def show
    @suggestion = Suggestion.find(params[:id])
  end

  def update_suggestion
    Suggestion.find(params[:id]).update_attributes(title: params[:suggestion][:title],
                                                   description: params[:suggestion][:description],
                                                   signup_preference: params[:suggestion][:signup_preference])
    redirect_to action: 'new', id: Suggestion.find(params[:id]).assignment_id
  end

  def new
    @suggestion = Suggestion.new
    session[:assignment_id] = params[:id]
    @suggestions = Suggestion.where(unityID: session[:user].name, assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  def create
    @suggestion = Suggestion.new(suggestion_params)
    @suggestion.assignment_id = session[:assignment_id]
    @assignment = Assignment.find(session[:assignment_id])
    @suggestion.status = 'Initiated'
    @suggestion.unityID = if params[:suggestion_anonymous].nil?
                            session[:user].name
                          else
                            ""
    end

    if @suggestion.save
      flash[:success] = 'Thank you for your suggestion!' if @suggestion.unityID != ''
      flash[:success] = 'You have submitted an anonymous suggestion. It will not show in the suggested topic table below.' if @suggestion.unityID == ''
    end
    redirect_to action: 'new', id: @suggestion.assignment_id
  end

  def submit
    if !params[:add_comment].nil?
      add_comment
    elsif !params[:approve_suggestion].nil?
      approve_suggestion
    elsif !params[:reject_suggestion].nil?
      reject_suggestion
    end
  end

  # this is a method for lazy team creation. Here may not be the right place for this method.
  # should be refactored into a static method in AssignmentTeam class. --Yang
  def create_new_team
    new_team = AssignmentTeam.create(name: 'Team_' + rand(10_000).to_s,
                                     parent_id: @signuptopic.assignment_id, type: 'AssignmentTeam')
    t_user = TeamsUser.create(team_id: new_team.id, user_id: @user_id)
    SignedUpTeam.create(topic_id: @signuptopic.id, team_id: new_team.id, is_waitlisted: 0)
    parent = TeamNode.create(parent_id: @signuptopic.assignment_id, node_object_id: new_team.id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
  end

  # If the user submits a suggestion and gets it approved -> Send email
  # If user submits a suggestion anonymously and it gets approved -> DOES NOT get an email
  def send_email
    proposer = User.find_by(id: @user_id)
    if proposer
      teams_users = TeamsUser.where(team_id: @team_id)
      cc_mail_list = []
      teams_users.each do |teams_user|
        cc_mail_list << User.find(teams_user.user_id).email if teams_user.user_id != proposer.id
      end
      Mailer.suggested_topic_approved_message(
        to: proposer.email,
        cc: cc_mail_list,
        subject: "Suggested topic '#{@suggestion.title}' has been approved",
        body: {
          approved_topic_name: @suggestion.title,
          proposer: proposer.name
        }
      ).deliver_now!
    end
  end

  def notification
    #--zhewei-----06/22/2015--------------------------------------------------------------------------------------
    # If you want to create a new team with topic and team members on view, you have to
    # 1. create new Team
    # 2. create new TeamsUser
    # 3. create new SignedUpTeam
    # 4. create new TeamNode (node_object_id of TeamNode is team_id)
    # 5. create new TeamUserNode (node_object_id of TeamUserNode is teams_user_id)
    #----------------------------------------------------------------------------------------------------------
    # if proposer's signup_pref is yes and does not have a team yet --> create team and assign topic
    # if proposer's signup_pref is yes, has a team, does not hold a topic yet --> assign topic
    # if proposer's signup_pref is yes, has a team and topic --> send email says that 'approved'
    # if proposer's signup_pref is no --> send email says that 'approved'
    if @suggestion.signup_preference == 'Y'
      # if this user do not have team in this assignment, create one for him/her and assign this topic to this team.
      if @team_id.nil?
        create_new_team
      else # this user has a team in this assignment, check whether this team has topic or not
        if @topic_id.nil?
          # clean waitlists
          SignedUpTeam.where(team_id: @team_id, is_waitlisted: 1).destroy_all
          SignedUpTeam.create(topic_id: @signuptopic.id, team_id: @team_id, is_waitlisted: 0)
        else
          @signuptopic.private_to = @user_id
          @signuptopic.save
          # if this team has topic, Expertiza will send an email (suggested_topic_approved_message) to this team
          send_email
        end
      end
    else
      # if this team has topic, Expertiza will send an email (suggested_topic_approved_message) to this team
      send_email
    end
  end

  def approve_suggestion
    approve
    notification
    redirect_to action: 'show', id: @suggestion
  end

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

  def suggestion_params
    params.require(:suggestion).permit(:assignment_id, :title, :description,
                                       :status, :unityID, :signup_preference)
  end

  def approve
    @suggestion = Suggestion.find(params[:id])
    @user_id = User.find_by(name: @suggestion.unityID).try(:id)
    if @user_id
      @team_id = TeamsUser.team_id(@suggestion.assignment_id, @user_id)
      @topic_id = SignedUpTeam.topic_id(@suggestion.assignment_id, @user_id)
    end
    @signuptopic = SignUpTopic.new
    @signuptopic.topic_identifier = 'S' + Suggestion.where("assignment_id = ? and id <= ?", @suggestion.assignment_id, @suggestion.id).size.to_s
    @signuptopic.topic_name = @suggestion.title
    @signuptopic.assignment_id = @suggestion.assignment_id
    @signuptopic.max_choosers = 1
    if @signuptopic.save && @suggestion.update_attribute('status', 'Approved')
      flash[:success] = 'The suggestion was successfully approved.'
    else
      flash[:error] = 'An error occurred when approving the suggestion.'
    end
  end
end
