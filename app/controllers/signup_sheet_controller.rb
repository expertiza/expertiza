# contains all functions related to management of the signup sheet for an assignment
# functions to add new topics to an assignment, edit properties of a particular topic, delete a topic, etc
# are included here

# A point to be taken into consideration is that :id (except when explicitly stated) here means topic id and not assignment id
# (this is referenced as :assignment id in the params has)
# The way it works is that assignments have their own id's, so do topics. A topic has a foreign key dependency on the assignment_id
# Hence each topic has a field called assignment_id which points which can be used to identify the assignment that this topic belongs
# to

class SignupSheetController < ApplicationController
  include AuthorizationHelper

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
    @signup_topic = SignUpTopic.new
    @signup_topic.assignment = Assignment.find(params[:id])
    @topic = @signup_topic
  end

  # This method is used to create signup topics
  # In this code params[:id] is the assignment id and not topic id. The intuition is
  # that assignment id will virtually be the signup sheet id as well as we have assumed
  # that every assignment will have only one signup sheet
  def create
    topic = SignUpTopic.where(topic_name: topic_params[:topic_name], assignment_id: params[:id]).first
    if topic.nil?
      setup_new_topic
    else
      update_existing_topic topic # Required?
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
      update_waitlist @topic
      @topic.update_attributes(topic_params)
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
    SignUpSheet.add_signup_topic(params[:id])
  end

  def set_values_for_new_topic
    @signup_topic = SignUpTopic.new
    @signup_topic.topic_identifier = topic_params[:topic_identifier]
    @signup_topic.topic_name = topic_params[:topic_name]
    @signup_topic.max_choosers = topic_params[:max_choosers]
    @signup_topic.category = topic_params[:category]
    @signup_topic.assignment_id = params[:id]
    @assignment = Assignment.find(params[:id])
  end

  # simple function that redirects ti the /add_signup_topics page
  def redirect_to_sign_up(assignment_id)
    redirect_to action: 'add_signup_topics', id: assignment_id
  end

  # simple function that redirects to assignment->edit->topic panel to display /add_signup_topics page
  def redirect_to_assignment_edit(assignment_id)
    redirect_to controller: 'assignments', action: 'edit', id: assignment_id
  end

  # method to return a list of topics for which a bid has been made by a team
  def compute_signed_up_topics
    signed_up_topics = []
    @bids.each do |bid|
      signup_topic = SignUpTopic.find_by(id: bid.topic_id)
      signed_up_topics << signup_topic if signup_topic
    end
    signed_up_topics &= @signup_topics
    return signed_up_topics
  end

  def list
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @signup_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    @slots_filled = SignUpTopic.find_slots_filled(@assignment.id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(@assignment.id)
    @show_actions = true
    @priority = 0
    team_id = @participant.team.try(:id)

    # if assignment is intelligent, want to know which topics the team has already bid on
    if @assignment.is_intelligent
      @bids = team_id.nil? ? [] : Bid.where(team_id: team_id).order(:priority)
      @bids = compute_signed_up_topics()
      @signup_topics -= @bids
    end

    @num_of_topics = @signup_topics.size
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
    render('signup_sheet/intelligent_topic_selection') && return if @assignment.is_intelligent
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

  # this function is used to delete a previous signup
  def delete_signup
    participant = AssignmentParticipant.find(params[:id])
    assignment = participant.assignment
    drop_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 6)
    # A student who has already submitted work should not be allowed to drop his/her topic!
    # (A student/team has submitted if participant directory_num is non-null or submitted_hyperlinks is non-null.)
    # If there is no drop topic deadline, student can drop topic at any time (if all the submissions are deleted)
    # If there is a drop topic deadline, student cannot drop topic after this deadline.
    if !participant.team.submitted_files.empty? || !participant.team.hyperlinks.empty?
      flash[:error] = 'You have already submitted your work, so you are not allowed to drop your topic.'
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].id, 'Dropping topic for already submitted a work: ' + params[:topic_id].to_s)
    elsif !drop_topic_deadline.nil? && (Time.now > drop_topic_deadline.due_at)
      flash[:error] = 'You cannot drop your topic after the drop topic deadline!'
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].id, 'Dropping topic for ended work: ' + params[:topic_id].to_s)
    else
      delete_signup_for_topic(assignment.id, params[:topic_id], session[:user].id)
      flash[:success] = 'You have successfully dropped your topic!'
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].id, 'Student has dropped the topic: ' + params[:topic_id].to_s)
    end
    redirect_to action: 'list', id: params[:id]
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
          if topic_due_date.nil? # create a new record
            TopicDueDate.create(
              due_at: instance_variable_get('@topic_' + deadline_type + '_due_date'),
              deadline_type_id: deadline_type_id,
              parent_id: topic.id,
              submission_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].submission_allowed_id,
              review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_allowed_id,
              review_of_review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_of_review_allowed_id,
              round: i,
              flag: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].flag,
              threshold: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].threshold,
              delayed_job_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].delayed_job_id,
              deadline_name: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].deadline_name,
              description_url: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].description_url,
              quiz_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].quiz_allowed_id,
              teammate_review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].teammate_review_allowed_id,
              type: 'TopicDueDate'
            )
          else # update an existed record
            topic_due_date.update_attributes(
              due_at: instance_variable_get('@topic_' + deadline_type + '_due_date'),
              submission_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].submission_allowed_id,
              review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_allowed_id,
              review_of_review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_of_review_allowed_id,
              quiz_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].quiz_allowed_id,
              teammate_review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].teammate_review_allowed_id
            )
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

  def setup_new_topic
    set_values_for_new_topic
    @signup_topic.micropayment = params[:topic][:micropayment] if @assignment.microtask?
    if @signup_topic.save
      undo_link "The topic: \"#{@signup_topic.topic_name}\" has been created successfully. "
      redirect_to edit_assignment_path(@signup_topic.assignment_id) + '#tabs-2'
    else
      render action: 'new', id: params[:id]
    end
  end

  def update_existing_topic(topic)
    update_waitlist topic
    topic.update_attributes(topic_params)
    redirect_to_sign_up(params[:id])
  end

  def update_waitlist(topic)
    # While saving the max choosers you should be careful; if there are users who have signed up for this particular
    # topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
    # there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
    # it.
    if SignedUpTeam.find_by(topic_id: topic.id).nil? || topic.max_choosers == topic_params[:max_choosers]
      return
    elsif topic.max_choosers.to_i < topic_params[:max_choosers].to_i
      topic.update_waitlisted_users topic_params[:max_choosers]
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

  def delete_signup_for_topic(assignment_id, topic_id, user_id)
    SignUpTopic.reassign_topic(user_id, assignment_id, topic_id)
  end

  def topic_params
    params.require(:topic).permit(:topic_identifier, :category, :topic_name, :micropayment, :description, :link, :max_choosers)
  end
end
