class SuggestionController < ApplicationController
  include AuthorizationHelper

  ##### action_allowed? #####
  # action_allowed? is used to determine if a user has the proper student or
  # ta privileges.
  def action_allowed?
    case params[:action]
    when 'create', 'new', 'student_view', 'student_edit', 'update', 'submit'
      current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end

  ##### add_comment #####
  # add_comment is associated with the ability to add comments when creating/editing/viewing suggestions
  # When a user attempts to perform the following actions on a suggestion, a box to enter a comment exists. Upon hitting
  # the button to submit, the "submit" function will check if a comment has been added to the suggestion, and
  # if so then this function will be called to process the entered comment. This is primarily done by creating a new instance
  # of SuggestionComment, where the entered text will be handled. The comment will then be associated with the user's credentials
  # and afterwards the user will be redirected to the respective pages.
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

  ##### list #####
  # list is associated with the view given when attempting to view all of the existing
  # suggestions for a specific assignment. This list is only viewable by Instructors and TA's.
  # To trigger this, a user with the required permissions can click "Manage", "Assignemnts", a corresponding
  # "View Suggestions" icon, and will be met with the list of assignments with the user's who created them
  # listed alongside the titles.
  def list
    @suggestions = Suggestion.where(assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  ##### student_view #####
  # student_view is associated with the view file used when a user of student permissions
  # attempts to view a suggestion's details further. The function here provides the exact
  # Suggestion needed for context with student_view.html.erb, so that it may display the
  # required details. It's triggered when a student selects the "View" option from a list of
  # Suggestions.
  def student_view
    @suggestion = Suggestion.find(params[:id])
  end

  ##### student_edit #####
  # student_edit is associated with the view file used when a user of student permissions
  # attempts to edit a suggestion's details further. The function here provides the exact
  # Suggestion needed for context with student_edit.html.erb, so that it may display the
  # required details. It's triggered when a student selects the "Edit" option for a Suggestion
  # they have permission to alter, which is likely one they'd previously created.
  def student_edit
    @suggestion = Suggestion.find(params[:id])
  end

  ##### show #####
  # show is another method that's only accessible to users with Instructor or TA status.
  # Rather than the student_view seen prior, this is triggered when a user in the list view
  # selects "View", which will show a page that can allow a user to approve or reject a suggestion,
  # which would trigger the approve and reject functions respectively.
  def show
    @suggestion = Suggestion.find(params[:id])
  end

  ##### update #####
  # update is a associated solely with a student's ability to edit their own suggestion with student_edit.
  # Whenever a student attempts to submit their "edit", it will redirect to the existing new and create actions
  # treating it as if it were being recreated. This is because the "edit" method is disabled by default to prevent
  # instructors and TA's from altering a student's suggestions from their view.
  def update
    Suggestion.find(params[:id]).update_attributes(title: params[:suggestion][:title],
                                                   description: params[:suggestion][:description],
                                                   signup_preference: params[:suggestion][:signup_preference])
    redirect_to action: 'new', id: Suggestion.find(params[:id]).assignment_id
  end

  ##### new #####
  # new is associated with the new view, which is triggered when a user with student permissions attempts to
  # create a new suggestion. It provides all of the assignment's information to the new.html.erb view, where a User
  # can then input all of the required fields to create a suggestion.
  def new
    @suggestion = Suggestion.new
    session[:assignment_id] = params[:id]
    @suggestions = Suggestion.where(unityID: session[:user].name, assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  ##### create #####
  # create is associated with the submission of a new Suggestion through the new.html.erb view. Whenever a User
  # attempts to submit their new Suggestion, this function will be called, and it'll save the suggestion.
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

  ##### submit #####
  # submit is associated with the "show" view seen by users with Instructor or TA permissions.
  # Whenever a user with these permissions wishes to submit their vote to approve/reject the provided suggestion,
  # as well as adding an optional comment, this function will be triggered. The button associated is "Submit Vote"
  # seen on "show.html.erb".
  def submit
    if !params[:add_comment].nil?
      add_comment
    elsif !params[:approve_suggestion].nil?
      approve_and_notify
    elsif !params[:reject].nil?
      reject
    end
  end

  ##### send_email #####
  # send_email is associated with the notify_suggester function, where if a a Suggestion
  # is approved and is not submitted anonymously, then this function will be called. It
  # will then construct an email to send to the entire user's team for the respective
  # assignment.
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

  ##### notify_suggester #####
  # notify_suggester is called whenever a suggestion is approved by the function "approve_suggestion_and_notify", and
  # when it's called it will check to see if the user is already in the team or if the topic hasn't been created.
  # If either of these haven't been created, it'll create the team or topic respectively, which doesn't provide a
  # notification through the Mailer in this portion of the code. Otherwise, it will queue an email through the Mailer
  # class to send an email with "notify_suggestion_approval".
  def notify_suggester
    if @suggestion.signup_preference == 'Y'
      if @team_id.nil?
        new_team = AssignmentTeam.create(name: 'Team_' + rand(10_000).to_s,
                                         parent_id: @signuptopic.assignment_id, type: 'AssignmentTeam')
        new_team.create_new_team(@user_id, @signuptopic)
      else
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

  ##### approve_and_notify #####
  # approve_and_notify is a function that calls both the approve function, which is responsible for
  # propogating the choice to approve a suggestion. Afterwards, it calls the "notify_suggester" function
  # to send out emails if that's appropriate.
  def approve_and_notify
    approve
    notify_suggester
    redirect_to action: 'show', id: @suggestion
  end

  ##### reject #####
  # reject is associated with the option shown to users with Instructor or TA permissions on
  # the "show.html.erb" page. If a user clicks the button "Reject suggestion", and then clicks
  # "Submit Vote", then this function will be triggered through the associated "submit" function.
  # The status of the suggestion will then be updated to reflect its rejected status, and a notice
  # will be given if it succeeds. Otherwise, an error notice will be given.
  def reject
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

  ##### approve #####
  # approve is associated with the option shown to users with Instructor or TA permissions on
  # the "show.html.erb" page. If a user clicks the button "Approve suggestion", and then clicks
  # "Submit Vote", then this function will be triggered through the associated "submit" function.
  # The status of the suggestion will then be updated to reflect its approved status, the team
  # and user will be grabbed, and a SignUpTopic will be created to reflect the suggestion going
  # from a "Suggestion" and now becoming a real topic that can be used in the assignment. A notice
  # will be given if it succeeds. Otherwise, an error notice will be given.
  def approve
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
