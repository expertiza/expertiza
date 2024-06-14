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
    action = params[:action]
    if student_action_allowed?(action)
      current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end
  
  # Checks if a student is allowed to perform a specific action.
  #
  # @param action [String] The action to be checked.
  # @return [Boolean] Returns true if the student is allowed to perform the action, otherwise false.
  def student_action_allowed?(action)
    # List of actions that students are allowed to perform
    student_actions = %w[set_priority sign_up delete_signup list show_team switch_original_topic_to_approved_suggested_topic publish_approved_suggested_topic]

    # Check if the action is included in the list of student actions
    if student_actions.include?(action)
      # Check if the current user has student privileges and the needed authorizations are present
      return current_user_has_student_privileges? && are_needed_authorizations_present?(params[:id], 'reader', 'submitter', 'reviewer')
    else
      return false
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
      setup_new_topic
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
      update_max_choosers @topic
      @topic.update_attributes(topic_identifier: params[:topic][:topic_identifier], category: params[:topic][:category], topic_name: params[:topic][:topic_name], micropayment: params[:topic][:micropayment], description: params[:topic][:description],link:params[:topic][:link] )
      flash[:success] = 'The topic has been successfully updated.'
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
    load_all_selected_topics
    @stopics.each(&:destroy)
    flash[:success] = 'All selected topics have been deleted successfully.'
    respond_to do |format|
      format.html { redirect_to edit_assignment_path(params[:assignment_id]) + '#tabs-2' }
      format.js {}
    end
  end

  # This loads all selected topics based on all the topic identifiers selected for that assignment into stopics variable
  def load_all_selected_topics
    @stopics = SignUpTopic.where(assignment_id: params[:assignment_id], topic_identifier: params[:topic_ids])
  end

  # This displays a page that lists all the available topics for an assignment.
  # Contains links that let an admin or Instructor edit, delete, view enrolled/waitlisted members for each topic
  # Also contains links to delete topics and modify the deadlines for individual topics. Staggered means that different topics can have different deadlines.
  def add_signup_topics
    load_add_signup_topics(params[:id])
    SignUpSheet.add_signup_topic(params[:id])
  end

  def add_signup_topics_staggered
    add_signup_topics
  end

  # retrieves all the data associated with the given assignment. Includes all topics,
  def load_add_signup_topics(assignment_id)
    @id = assignment_id
    @sign_up_topics = SignUpTopic.where('assignment_id = ?', assignment_id)
    @slots_filled = SignUpTopic.find_slots_filled(assignment_id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(assignment_id)

    @assignment = Assignment.find(assignment_id)
    # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    # Though called participants, @participants are actually records in signed_up_teams table, which
    # is a mapping table between teams and topics (waitlisted recorded are also counted)
    @participants = SignedUpTeam.find_team_participants(assignment_id, session[:ip])
  end

  def set_values_for_new_topic
    topic_helper = SignUpTopicHelper.new(params, params[:id])
    @sign_up_topic = topic_helper.build
    @assignment = Assignment.find(params[:id])
  end

  # simple function that redirects ti the /add_signup_topics or the /add_signup_topics_staggered page depending on assignment type
  # staggered means that different topics can have different deadlines.
  def redirect_to_sign_up(assignment_id)
    assignment = Assignment.find(assignment_id)
    assignment.staggered_deadline == true ? (redirect_to action: 'add_signup_topics_staggered', id: assignment_id) : (redirect_to action: 'add_signup_topics', id: assignment_id)
  end

  # simple function that redirects to assignment->edit->topic panel to display /add_signup_topics or the /add_signup_topics_staggered page
  # staggered means that different topics can have different deadlines.
  def redirect_to_assignment_edit(assignment_id)
    redirect_to controller: 'assignments', action: 'edit', id: assignment_id
  end

  def list
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @slots_filled = SignUpTopic.find_slots_filled(@assignment.id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(@assignment.id)
    @show_actions = true
    @priority = 0
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    @max_team_size = @assignment.max_team_size
    team_id = @participant.team.try(:id)
    @use_bookmark = @assignment.use_bookmark

    if @assignment.is_intelligent
      @bids = team_id.nil? ? [] : Bid.where(team_id: team_id).order(:priority)
      signed_up_topics = []
      @bids.each do |bid|
        sign_up_topic = SignUpTopic.find_by(id: bid.topic_id)
        signed_up_topics << sign_up_topic if sign_up_topic
      end
      signed_up_topics &= @sign_up_topics
      @sign_up_topics -= signed_up_topics
      @bids = signed_up_topics
    end

    @num_of_topics = @sign_up_topics.size
    @signup_topic_deadline = @assignment.due_dates.find_by(deadline_type_id: 7)
    @drop_topic_deadline = @assignment.due_dates.find_by(deadline_type_id: 6)
    @student_bids = team_id.nil? ? [] : Bid.where(team_id: team_id)

    unless @assignment.due_dates.find_by(deadline_type_id: 1).nil?
      @show_actions = false if !@assignment.staggered_deadline? && (@assignment.due_dates.find_by(deadline_type_id: 1).due_at < Time.now)

      # Find whether the user has signed up for any topics; if so the user won't be able to
      # sign up again unless the former was a waitlisted topic
      # if team assignment, then team id needs to be passed as parameter else the user's id
      users_team = SignedUpTeam.find_team_users(@assignment.id, session[:user].id)
      @selected_topics = if users_team.empty?
                           nil
                         else
                           SignedUpTeam.find_user_signup_topics(@assignment.id, users_team.first.t_id)
                         end
    end
    render('sign_up_sheet/intelligent_topic_selection') && return if @assignment.is_intelligent
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
  def signup_as_instructor; end

  def signup_as_instructor_action
    user = User.find_by(name: params[:username])
    if user.nil? # validate invalid user
      flash[:error] = 'That student does not exist!'
    else
      assignment=Assignment.find(params[:assignment_id])
      topic=SignUpTopic.find(params[:topic_id])
      assignment_id = assignment.id  
      topic_id = topic.id
      if user_registered_for_assignment?(user, assignment_id)
        process_signup_as_instructor_request(assignment_id,user,topic_id)
      else
        log_message("The student is not registered for the assignment: #{user.id}")
      end
    end
    redirect_to controller: 'assignments', action: 'edit', id: assignment_id
end

  def user_registered_for_assignment?(user, assignment_id) # to check if user has registered for the assignment or not.
    if AssignmentParticipant.exists?(user_id: user.id, parent_id: assignment_id)
      true
    else
      flash[:error] = 'The student is not registered for the assignment!'
      false
    end
  end

  def log_message(message) # function to log the message
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', message)
  end

  def process_signup_as_instructor_request(assignment_id,user,topic_id) # function to add user for a given assignment and given topic
    if SignUpSheet.signup_team(assignment_id, user.id, topic_id)
      flash[:success] = 'You have successfully signed up the student for the topic!'
      log_message("Instructor signed up student for topic: #{topic_id}")
    else
      flash[:error] = 'The student has already signed up for a topic!'
      log_message('Instructor is signing up a student who already has a topic')
    end
  end

# This method centralizes the shared functionality, reducing redundancy and improving maintainability
#this function is used to delete a previous signup
  def remove_student_from_given_topic(user_action, participant, participant_id_to_be_dropped, assignment, drop_topic_deadline, topic_id)
    if !participant.team.submitted_files.empty? || !participant.team.hyperlinks.empty?
    # Handle case where participant has already submitted work
    flash[:error] = user_action.set_error_if_work_submitted
    ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].id, "Dropping topic for already submitted work: #{topic_id}")
  elsif !drop_topic_deadline.nil? && (Time.now > drop_topic_deadline.due_at)
    # Handle case where drop topic deadline has passed
    flash[:error] = user_action.set_error_if_deadline_passed
    ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].id, 'Dropping topic for ended work: ' + params[:topic_id].to_s)
  else
    # No errors, proceed with dropping topic
    user_action.delete_signup_for_topic(assignment.id,topic_id,participant_id_to_be_dropped)
    flash[:success] = user_action.set_success_message_after_delete
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].id, 'Student has dropped the topic: ' + topic_id.to_s)
  end
end

# Following method is for student to delete self from any toptic within a assignment
def delete_signup
  user_action = StudentDeleteSignupAction.new
  participant = AssignmentParticipant.find(params[:id])
  assignment = participant.assignment
  drop_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 6)
  topic_id = params[:topic_id]
  remove_student_from_given_topic(user_action, participant, session[:user].id, assignment, drop_topic_deadline, topic_id)
  redirect_to action: 'list', id: params[:id]
end

# Following method is for instructor to delete a student from any toptic within a assignment
def delete_signup_as_instructor
  user_action = InstructorDeleteSignupAction.new
  team = Team.find(params[:id])
  assignment = Assignment.find(team.parent_id)
  user = TeamsUser.find_by(team_id: team.id).user
  participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id)
  drop_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 6)
  topic_id = params[:topic_id]
  remove_student_from_given_topic(user_action, participant ,participant.user_id, assignment, drop_topic_deadline, topic_id)
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
  def save_topic_deadlines
    assignment = Assignment.find(params[:assignment_id])
    @assignment_submission_due_dates = assignment.due_dates.select { |due_date| due_date.deadline_type_id == 1 }
    @assignment_review_due_dates = assignment.due_dates.select { |due_date| due_date.deadline_type_id == 2 }
    due_dates = params[:due_date]
    topics = SignUpTopic.where(assignment_id: params[:assignment_id])
    review_rounds = assignment.num_review_rounds
    topics.each_with_index do |topic, index|
      (1..review_rounds).each do |i|
        @topic_submission_due_date = due_dates[topics[index].id.to_s + '_submission_' + i.to_s + '_due_date']
        @topic_review_due_date = due_dates[topics[index].id.to_s + '_review_' + i.to_s + '_due_date']
        @assignment_submission_due_date = DateTime.parse(@assignment_submission_due_dates[i - 1].due_at.to_s).strftime('%Y-%m-%d %H:%M')
        @assignment_review_due_date = DateTime.parse(@assignment_review_due_dates[i - 1].due_at.to_s).strftime('%Y-%m-%d %H:%M')
        %w[submission review].each do |deadline_type|
          deadline_type_id = DeadlineType.find_by_name(deadline_type).id
          next if instance_variable_get('@topic_' + deadline_type + '_due_date') == instance_variable_get('@assignment_' + deadline_type + '_due_date')

          topic_due_date = begin
                             TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_id, round: i).first
                           rescue StandardError
                             nil
                           end
          due_date_instance=instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1]  #applying DRY principle and removing multiple instance_variable_get calls
          # Retrieve the due date for the current deadline type
          due_at=instance_variable_get('@topic_' + deadline_type + '_due_date')                 
          if topic_due_date.nil? # create a new record
            # Create a new record if the topic due date does not exist
            create_topic_due_date(i,topic,deadline_type_id,due_date_instance,due_at)
          else # update an existed record 
            topic_due_date.update_attributes(due_at: due_at,submission_allowed_id: due_date_instance.submission_allowed_id,review_allowed_id: due_date_instance.review_allowed_id,
            review_of_review_allowed_id: due_date_instance.review_of_review_allowed_id,quiz_allowed_id: due_date_instance.quiz_allowed_id,teammate_review_allowed_id: due_date_instance.teammate_review_allowed_id)
          end
        end
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
    update_topic_privacy_status

    # Change to dynamic finder method to prevent sql injection
    update_signed_up_team_topic(team_id)
    # check the waitlist of original topic. Let the first waitlisted team hold the topic, if exists.
    assign_topic_to_waitlisted_team(original_topic_id,assignment.id)
    
    redirect_to action: 'list', id: params[:id]
  end

  def update_topic_privacy_status
    if SignUpTopic.exists?(id: params[:topic_id])
      SignUpTopic.find(params[:topic_id]).update_attribute(:private_to, nil)
    else
      flash[:error] = 'Signup topic does not exist.'
    end
  end

  # Updates the topic assigned to a signed-up team.
  #
  # @param team_id [Integer] The ID of the team whose topic is being updated.
  def update_signed_up_team_topic(team_id)
    signed_up_team = SignedUpTeam.find_by(team_id: team_id, is_waitlisted: 0)
    signed_up_team.update_attribute('topic_id', params[:topic_id].to_i) if signed_up_team
  end

  # Assigns a new topic to a team that was previously waitlisted for another topic.
  #
  # @param original_topic_id [Integer] The ID of the original topic the team was waitlisted for.
  # @param assignment_id [Integer] The ID of the assignment to which the topic is being assigned.
  def assign_topic_to_waitlisted_team(original_topic_id,assignment_id)
    waitlisted_team = SignedUpTeam.where(topic_id: original_topic_id, is_waitlisted: 1).first
    return unless waitlisted_team
  
    # Find the user ID of the first user in the team.
    waitlisted_first_team_first_user_id = TeamsUser.where(team_id: waitlisted_team.team_id).first.user_id
    SignUpSheet.signup_team(assignment_id, waitlisted_first_team_first_user_id, original_topic_id)
  end

  def publish_approved_suggested_topic
    SignUpTopic.find_by(id: params[:topic_id]).update_attribute(:private_to, nil) if SignUpTopic.exists?(id: params[:topic_id])
    redirect_to action: 'list', id: params[:id]
  end

  private

  def setup_new_topic
    set_values_for_new_topic
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
    redirect_to_sign_up(params[:id])
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
  def ad_info(_assignment_id, topic_id)
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

end
