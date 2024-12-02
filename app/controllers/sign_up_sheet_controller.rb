# contains all functions related to management of the signup sheet for an assignment
# functions to add new topics to an assignment, edit properties of a particular topic, delete a topic, etc
# are included here

# A point to be taken into consideration is that :id (except when explicitly stated) here means topic id and not assignment id
# (this is referenced as :assignment id in the params has)
# The way it works is that assignments have their own id's, so do topics. A topic has a foreign key dependency on the assignment_id
# Hence each topic has a field called assignment_id which points which can be used to identify the assignment that this topic belongs
# to

class SignUpSheetController < ApplicationController
  include AuthorizationHelper
  include SignUpSheetHelper
  require 'rgl/adjacency'
  require 'rgl/dot'
  require 'rgl/topsort'

  def action_allowed?
    case params[:action]
    when 'set_priority', 'sign_up', 'delete_signup', 'list', 'show_team', 'switch_original_topic_to_approved_suggested_topic', 'publish_approved_suggested_topic'
      (current_user_has_student_privileges? &&
          (%w[list].include? action_name) &&
          are_needed_authorizations_present?(params[:id], 'reader', 'submitter', 'reviewer')) ||
        current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end

  # Includes functions for team management. Refer /app/helpers/ManageTeamHelper
  include ManageTeamHelper
  # Includes functions for Dead line management. Refer /app/helpers/DeadLineHelper
  include DeadlineHelper

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

  def controller_locale
    locale_for_student
  end

  # Prepares the form for adding a new topic. Used in conjunction with create
  def new
    @id = params[:id]
    @sign_up_topic = SignUpTopic.new
    @sign_up_topic.assignment = Assignment.find(params[:id])
    @topic = @sign_up_topic
  end

  # This method is used to create signup topics
  # In this code params[:id] is the assignment id and not topic id. The intuition is
  # that assignment id will virtually be the signup sheet id as well as we have assumed
  # that every assignment will have only one signup sheet
  def create
    topic = SignUpTopic.where(topic_name: params[:topic][:topic_name], assignment_id: params[:id]).first
    if topic.nil?
      create_and_configure_signup_topic
    else
      update_existing_topic topic
    end
  end

  # This method is used to delete signup topics
  # Renaming delete method to destroy for rails 4 compatible
  def destroy
    @topic = SignUpTopic.find(params[:id])
    assignment = Assignment.find(params[:assignment_id])
    if @topic
      @topic.destroy
      undo_link("The topic: \"#{@topic.topic_name}\" has been successfully deleted. ")
    else
      flash[:error] = 'The topic could not be deleted.'
    end
    # Akshay - redirect to topics tab if there are still any topics left, otherwise redirect to
    # assignment's edit page
    if assignment.topics?
      redirect_to edit_assignment_path(params[:assignment_id]) + '#tabs-2'
    else
      redirect_to edit_assignment_path(params[:assignment_id])
    end
  end

  # prepares the page. shows the form which can be used to enter new values for the different properties of an assignment
  def edit
    @topic = SignUpTopic.find(params[:id])
  end

  # updates the database tables to reflect the new values for the assignment. Used in conjunction with edit
  def update
    @topic = SignUpTopic.find(params[:id])
    if @topic
      @topic.topic_identifier = params[:topic][:topic_identifier]
      update_max_choosers @topic
      @topic.category = params[:topic][:category]
      @topic.topic_name = params[:topic][:topic_name]
      @topic.micropayment = params[:topic][:micropayment]
      @topic.description = params[:topic][:description]
      @topic.link = params[:topic][:link]
      @topic.save
      undo_link("The topic: \"#{@topic.topic_name}\" has been successfully updated. ")
    else
      flash[:error] = 'The topic could not be updated.'
    end
    # Akshay - correctly changing the redirection url to topics tab in edit assignment view.
    redirect_to edit_assignment_path(params[:assignment_id]) + '#tabs-2'
  end

  # This deletes all topics for the given assignment
  def delete_all_topics_for_assignment
    topics = SignUpTopic.where(assignment_id: params[:assignment_id])
    topics.each(&:destroy)
    flash[:success] = 'All topics have been deleted successfully.'
    respond_to do |format|
      format.html { redirect_to edit_assignment_path(params[:assignment_id]) }
      format.js {}
    end
  end

  # This deletes all selected topics for the given assignment
  def delete_all_selected_topics
    fetch_selected_topics_by_assignment
    @stopics.each(&:destroy)
    flash[:success] = 'All selected topics have been deleted successfully.'
    respond_to do |format|
      format.html { redirect_to edit_assignment_path(params[:assignment_id]) + '#tabs-2' }
      format.js {}
    end
  end

  # This loads all selected topics based on all the topic identifiers selected for that assignment into stopics variable
  def fetch_selected_topics_by_assignment
    @stopics = SignUpTopic.where(assignment_id: params[:assignment_id], topic_identifier: params[:topic_ids])
  end

  # This displays a page that lists all the available topics for an assignment.
  # Contains links that let an admin or Instructor edit, delete, view enrolled/waitlisted members for each topic
  # Also contains links to delete topics and modify the deadlines for individual topics. Staggered means that different topics can have different deadlines.
  def add_signup_topics
    load_signup_data_for_assignment(params[:id])
    SignUpSheet.add_signup_topic(params[:id])
  end

  def add_signup_topics_staggered
    add_signup_topics
  end

  # retrieves all the data associated with the given assignment. Includes all topics,
  def load_signup_data_for_assignment(assignment_id)

    #Set the instance variable to store the assignment ID
    @id = assignment_id

    #Fetch all sign-up topics associated with the given assignment ID
    @sign_up_topics = SignUpTopic.where('assignment_id = ?', assignment_id)

    #Retrieve the number of slots filled for the sign-up topics in the assignment
    @slots_filled = SignUpTopic.find_slots_filled(assignment_id)

    #Retrieve the number of slots waitlisted for the sign-up topics in the assignment
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(assignment_id)

    #Get the assignment details for the given ID
    @assignment = Assignment.find(assignment_id)

    # Fetch participants (from signed-up teams table) for the assignment.
    # This includes both teams that have successfully signed up and those on the waitlist.
    # The `session[:ip]` is used here, to filter or log participant-related data based on the user's session IP.
    @participants = SignedUpTeam.find_team_participants(assignment_id, session[:ip])

  end


  def initialize_new_sign_up_topic
    @sign_up_topic = SignUpTopic.new
    @sign_up_topic.topic_identifier = params[:topic][:topic_identifier]
    @sign_up_topic.topic_name = params[:topic][:topic_name]
    @sign_up_topic.max_choosers = params[:topic][:max_choosers]
    @sign_up_topic.category = params[:topic][:category]
    @sign_up_topic.assignment_id = params[:id]
    @assignment = Assignment.find(params[:id])
  end

  # simple function that redirects ti the /add_signup_topics or the /add_signup_topics_staggered page depending on assignment type
  # staggered means that different topics can have different deadlines.
  def redirect_to_signup(assignment_id)
    assignment = Assignment.find(assignment_id)
    assignment.staggered_deadline == true ? (redirect_to action: 'add_signup_topics_staggered', id: assignment_id) : (redirect_to action: 'add_signup_topics', id: assignment_id)
  end

  # simple function that redirects to assignment->edit->topic panel to display /add_signup_topics or the /add_signup_topics_staggered page
  # staggered means that different topics can have different deadlines.
  def redirect_to_assignment_edit(assignment_id)
    redirect_to controller: 'assignments', action: 'edit', id: assignment_id
  end

  def list
    # Fetch participant and assignment details
    @participant = AssignmentParticipant.find(params[:id].to_i)
    fetch_assignment_details(@participant)
  
    # Fetch deadline information
    fetch_deadlines(@assignment)
  
    # Determine if actions can be shown based on deadlines
    @show_actions = !set_action_display_status(@assignment)
  
    # Determine user's selected topics and team-related information
    user_sign_up_status(@assignment, session[:user].id)
    team_id = @participant.team.try(:id)
  
    # Handle intelligent assignments
    if @assignment.is_intelligent
      @bids = team_id.nil? ? [] : Bid.where(team_id: team_id).order(:priority)
  
      # Collect and filter topics based on bids
      signed_up_topics = @bids.map { |bid| SignUpTopic.find_by(id: bid.topic_id) }.compact
      signed_up_topics &= @sign_up_topics
      @sign_up_topics -= signed_up_topics
      @bids = signed_up_topics
    else
      @bids = []
    end
  
    # Calculate the size of the signup topic list
    @num_of_topics = @sign_up_topics.size
  
    # Store bid information
    @student_bids = team_id.nil? ? [] : Bid.where(team_id: team_id)
  
    # Render the intelligent topic selection view if applicable
    if @assignment.is_intelligent
      render('sign_up_sheet/intelligent_topic_selection') && return
    end
  
    # Default rendering
    render('sign_up_sheet/list')
  end
  

  def sign_up
    @assignment = AssignmentParticipant.find(params[:id]).assignment
    @user_id = session[:user].id
    # Always use team_id ACS
    # s = Signupsheet.new
    # Team lazy initialization: check whether the user already has a team for this assignment
    flash[:error] = "You've already signed up for a topic!" unless SignUpSheet.signup_team(@assignment.id, @user_id, params[:topic_id])
    redirect_to action: 'list', id: params[:id]
  end

  # routes to new page to specify student
  def sign_up_as_instructor; end
  # This method routes the instructor to a new page where it requests a student to sign up
  # This student id along with assignment and topic id is then used in the signup_as_instructor function
  # renamed from signup_as_instructor to select_student_for_signup for better clarity
  def select_student_for_signup; end


  def sign_up_as_instructor_action
  user = User.find_by(name: params[:username])

  # Check if the user is nil (i.e., user not found in the database)
  # If user is nil, display an error message to the user indicating the student does not exist
  # Log the information for debugging or tracking purposes
  # Redirect the user back to the 'edit' page of the current assignment
  if user.nil?
    flash[:error] = 'That student does not exist!'
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Student does not exist')
    return redirect_to controller: 'assignments', action: 'edit', id: params[:assignment_id]
  end

  # Check if there is an AssignmentParticipant record with the given user ID and assignment ID
  # If no such record exists, display an error message indicating the student is not registered for the assignment
  # Log this information for debugging or tracking purposes, including the user ID
  # Redirect the user back to the 'edit' page of the current assignment
  unless AssignmentParticipant.exists?(user_id: user.id, parent_id: params[:assignment_id])
    flash[:error] = 'The student is not registered for the assignment!'
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', "Student is not registered for the assignment: #{user.id}")
    return redirect_to controller: 'assignments', action: 'edit', id: params[:assignment_id]
  end

  # Attempt to sign up the student for the specified topic using the signup_team method
  # If successful, display a success message indicating the student has been signed up for the topic
  # Log the action for tracking, including the topic ID
  # If the signup fails (e.g., the student is already signed up for a topic), display an error message
  # Log this information for tracking purposes
  # Redirect the user back to the 'edit' page of the current assignment
  if SignUpSheet.signup_team(params[:assignment_id], user.id, params[:topic_id])
    flash[:success] = 'You have successfully signed up the student for the topic!'
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', "Instructor signed up student for topic: #{params[:topic_id]}")
  else
    flash[:error] = 'The student has already signed up for a topic!'
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Instructor is signing up a student who already has a topic')
  end

  redirect_to controller: 'assignments', action: 'edit', id: params[:assignment_id]
end

  # Define the delete_signup action
  # Fetch the participant, assignment, and drop topic deadline based on the given parameters
  # Define error messages for situations where the topic cannot be dropped (due to submission or deadline)
  # Check if the participant is allowed to drop the topic based on the submission status and deadline
  # If dropping the topic is allowed, find the user's team for the assignment and delete their signup for the specified topic
  # Display a success message indicating the topic has been dropped
  # Log this action for tracking purposes, including the topic ID
  # Redirect the user to the 'list' page for the current assignment
  def delete_signup

    participant, assignment, drop_topic_deadline = fetch_participant_and_assignment(params[:id])
    submission_error = 'You have already submitted your work, so you are not allowed to drop your topic.'
    deadline_error = 'You cannot drop your topic after the drop topic deadline!'    
    if eligible_to_drop_topic?(participant, drop_topic_deadline, submission_error, deadline_error)
      users_team = Team.find_team_users(assignment.id, session[:user].id)
      delete_signup_for_topic(params[:topic_id], users_team[0].t_id)
      flash[:success] = 'You have successfully dropped your topic!'
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].id, 'Student has dropped the topic: ' + params[:topic_id].to_s)
    end
  
    redirect_to action: 'list', id: params[:id]
  end

  # Find the team associated with the given team ID parameter
  # Retrieve the assignment, participant, and drop topic deadline based on the team
  # Define error messages for scenarios where the student cannot be removed (due to submission or deadline)
  # Check if the participant can be removed from the topic based on submission status and deadline constraints
  # If removal is allowed, delete the student's signup for the specified topic using the team's ID
  # Display a success message indicating the student has been dropped from the topic
  # Log this action for tracking purposes, including the topic ID
  # Redirect the instructor back to the 'edit' page of the assignment
  def delete_signup_as_instructor

    team = Team.find(params[:id])
    assignment, participant, drop_topic_deadline = fetch_participant_by_team_and_assignment(team)
    submission_error = 'The student has already submitted their work, so you are not allowed to remove them.'
    deadline_error = 'You cannot drop a student after the drop topic deadline!'

    if eligible_to_drop_topic?(participant, drop_topic_deadline, submission_error, deadline_error)
      delete_signup_for_topic(params[:topic_id], team.id)
      flash[:success] = 'You have successfully dropped the student from the topic!'
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].id, 'Student has been dropped from the topic: ' + params[:topic_id].to_s)
    end

    redirect_to controller: 'assignments', action: 'edit', id: assignment.id
  end

  def set_priority
    participant = AssignmentParticipant.find_by(id: params[:participant_id])
    assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
    team_id = participant.team.try(:id)
    unless team_id
      # Zhewei: team lazy initialization
      SignUpSheet.signup_team(assignment_id, participant.user.id)
      team_id = participant.team.try(:id)
    end
    if params[:topic].nil?
      # All topics are deselected by current team
      Bid.where(team_id: team_id).destroy_all
    else
      @bids = Bid.where(team_id: team_id)
      signed_up_topics = Bid.where(team_id: team_id).map(&:topic_id)
      # Remove topics from bids table if the student moves data from Selection table to Topics table
      # This step is necessary to avoid duplicate priorities in Bids table
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        Bid.where(topic_id: topic, team_id: team_id).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = Bid.where(topic_id: topic_id, team_id: team_id)
        if bid_existence.empty?
          Bid.create(topic_id: topic_id, team_id: team_id, priority: index + 1)
        else
          Bid.where(topic_id: topic_id, team_id: team_id).update_all(priority: index + 1)
        end
      end
    end
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end

  # If the instructor needs to explicitly change the start/due dates of the topics
  # This is true in case of a staggered deadline type assignment. Individual deadlines can
  # be set on a per topic and per round basis

  # This method saves or updates the due dates for submission and review associated
  # with topics for a specified assignment. The following refactoring changes have
  # been implemented to improve code quality:
  #
  # 1. Use of Local Variables: Local variables are used instead of instance 
  #    variables to enhance clarity and encapsulate the method's state.
  #
  # 2. Safe Navigation Operator: The code utilizes the safe navigation operator
  #    (`&.`) to avoid potential nil errors when accessing due dates from the assignment's
  #    due dates, ensuring more robust error handling.
  #
  # 3. Enhanced Readability: Overall structure and variable naming are 
  #    maintained to promote readability and maintainability.

  def save_topic_deadlines

    assignment = Assignment.find(params[:assignment_id])
    topics = SignUpTopic.where(assignment_id: params[:assignment_id])
    due_dates = params[:due_date]
    review_rounds = assignment.num_review_rounds

    @assignment_submission_due_dates, @assignment_review_due_dates = fetch_assignment_due_dates(assignment)

    topics.each do |topic|
     (1..review_rounds).each do |round|
       process_due_dates_for_topic_and_round(topic, round, due_dates)
    end
   end
   redirect_to_assignment_edit(params[:assignment_id])
 end       
  # This method is called when a student click on the trumpet icon. So this is a bad method name. --Yang
  def show_team
    assignment = Assignment.find(params[:assignment_id])
    topic = SignUpTopic.find(params[:id])
    if assignment && topic
      @results = ad_info(assignment.id, topic.id)
      @results.each do |result|
        result.keys.each do |key|
          @current_team_name = result[key] if key.equal? :name
        end
      end
      @results.each do |result|
        @team_members = ''
        TeamsUser.where(team_id: result[:team_id]).each do |teamuser|
          @team_members += User.find(teamuser.user_id).name + ' '
        end
      end
      # @team_members = find_team_members(topic)
    end
  end

  def switch_original_topic_to_approved_suggested_topic
    assignment = AssignmentParticipant.find(params[:id]).assignment
    team_id = TeamsUser.team_id(assignment.id, session[:user].id)

    # Tmp variable to store topic id before change
    original_topic_id = SignedUpTeam.topic_id(assignment.id.to_i, session[:user].id)

    # Check if this sign up topic exists
    if SignUpTopic.exists?(id: params[:topic_id])
      SignUpTopic.find_by(id: params[:topic_id]).update_attribute(:private_to, nil)
    else
      # Else flash an error
      flash[:error] = 'Signup topic does not exist.'
    end

    # Change to dynamic finder method to prevent sql injection
    if SignedUpTeam.exists?(team_id: team_id, is_waitlisted: 0)
      SignedUpTeam.where(team_id: team_id, is_waitlisted: 0).first.update_attribute('topic_id', params[:topic_id].to_i)
    end
    # check the waitlist of original topic. Let the first waitlisted team hold the topic, if exists.
    waitlisted_teams = SignedUpTeam.where(topic_id: original_topic_id, is_waitlisted: 1)
    if waitlisted_teams.present?
      waitlisted_first_team_first_user_id = TeamsUser.where(team_id: waitlisted_teams.first.team_id).first.user_id
      SignUpSheet.signup_team(assignment.id, waitlisted_first_team_first_user_id, original_topic_id)
    end
    redirect_to action: 'list', id: params[:id]
  end

  def publish_approved_suggested_topic
    SignUpTopic.find_by(id: params[:topic_id]).update_attribute(:private_to, nil) if SignUpTopic.exists?(id: params[:topic_id])
    redirect_to action: 'list', id: params[:id]
  end

  private

  def create_and_configure_signup_topic
    initialize_new_sign_up_topic
    @sign_up_topic.micropayment = params[:topic][:micropayment] if @assignment.microtask?
    if @sign_up_topic.save
      undo_link "The topic: \"#{@sign_up_topic.topic_name}\" has been created successfully. "
      redirect_to edit_assignment_path(@sign_up_topic.assignment_id) + '#tabs-2'
    else
      render action: 'new', id: params[:id]
    end
  end

  def update_existing_topic(topic)
    topic.topic_identifier = params[:topic][:topic_identifier]
    update_max_choosers(topic)
    topic.category = params[:topic][:category]
    # topic.assignment_id = params[:id]
    topic.save
    redirect_to_signup(params[:id])
  end

  def update_max_choosers(topic)
    # While saving the max choosers you should be careful; if there are users who have signed up for this particular
    # topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
    # there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
    # it.
    if SignedUpTeam.find_by(topic_id: topic.id).nil? || topic.max_choosers == params[:topic][:max_choosers]
      topic.max_choosers = params[:topic][:max_choosers]
    elsif topic.max_choosers.to_i < params[:topic][:max_choosers].to_i
      topic.update_waitlisted_users params[:topic][:max_choosers]
      topic.max_choosers = params[:topic][:max_choosers]
    else
      flash[:error] = 'The value of the maximum number of choosers can only be increased! No change has been made to maximum choosers.'
    end
  end

  # get info related to the ad for partners so that it can be displayed when an assignment_participant
  # clicks to see ads related to a topic
  def fetch_advertisement_info_for_topic(_assignment_id, topic_id)
    @ad_information = []
    @signed_up_teams = SignedUpTeam.where(topic_id: topic_id)
    # Iterate through the results of the query and get the required attributes
    @signed_up_teams.each do |signed_up_team|
      team = signed_up_team.team
      topic = signed_up_team.topic
      ad_map = {}
      ad_map[:team_id] = team.id
      ad_map[:comments_for_advertisement] = team.comments_for_advertisement
      ad_map[:name] = team.name
      ad_map[:assignment_id] = topic.assignment_id
      ad_map[:advertise_for_partner] = team.advertise_for_partner

      # Append to the list
      @ad_information.append(ad_map)
    end
    @ad_information
  end

  def delete_signup_for_topic(topic_id, team_id)
    # Delete a signup record for a specific topic and team.

    # Find the SignUpTopic record with the specified topic_id using the `find_by` method.
    @sign_up_topic = SignUpTopic.find_by(id: topic_id)
    # Check if the @sign_up_topic record exists (is not nil).
    unless @sign_up_topic.nil?
       # If the @sign_up_topic record exists, reassign the topic for the specified team by calling the `reassign_topic` 
       # instance method of SignUpTopic.
      @sign_up_topic.reassign_topic(team_id)
    end 
  end


  private

  # Method to fetch participant, assignment, and drop topic deadline

  def fetch_participant_and_assignment(participant_id)
    participant = AssignmentParticipant.find(participant_id)
    assignment = participant.assignment
    drop_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 6)
    [participant, assignment, drop_topic_deadline]
  end



  # Method to fetch assignment, participant, and drop topic deadline by team

  def fetch_participant_by_team_and_assignment(team)
    assignment = Assignment.find(team.parent_id)
    user = TeamsUser.find_by(team_id: team.id).user
    participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id)
    drop_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 6)
    [assignment, participant, drop_topic_deadline]
  end



  # Method to check if the topic can be dropped based on submission and deadline

  def eligible_to_drop_topic?(participant, drop_topic_deadline, submission_error, deadline_error)
    if !participant.team.submitted_files.empty? || !participant.team.hyperlinks.empty?
      flash[:error] = submission_error
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].id, 'Dropping topic for already submitted work: ' + params[:topic_id].to_s)
      false
    elsif !drop_topic_deadline.nil? && (Time.now > drop_topic_deadline.due_at)
      flash[:error] = deadline_error
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].id, 'Dropping topic for ended work: ' + params[:topic_id].to_s)
      false
    else
      true
   end
  end

end


