# contains all functions related to management of the signup sheet for an assignment
# functions to add new topics to an assignment, edit properties of a particular topic, delete a topic, etc
# are included here

# A point to be taken into consideration is that :id (except when explicitly stated) here means topic id and not assignment id
# (this is referenced as :assignment id in the params has)
# The way it works is that assignments have their own id's, so do topics. A topic has a foreign key dependecy on the assignment_id
# Hence each topic has a field called assignment_id which points which can be used to identify the assignment that this topic belongs
# to

class SignUpSheetController < ApplicationController
  require 'rgl/adjacency'
  require 'rgl/dot'
  require 'rgl/topsort'

  def action_allowed?
    case params[:action]
    when 'set_priority', 'sign_up', 'delete_signup', 'list', 'show_team', 'switch_original_topic_to_approved_suggested_topic', 'publish_approved_suggested_topic'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and ((%w(list).include? action_name) ? are_needed_authorizations_present? : true)
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  # Includes functions for team management. Refer /app/helpers/ManageTeamHelper
  include ManageTeamHelper
  # Includes functions for Dead line management. Refer /app/helpers/DeadLineHelper
  include DeadlineHelper

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: [:destroy, :create, :update],
         redirect_to: {action: :list}

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

    # if the topic already exists then update
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
    if @topic
      @topic.destroy
      undo_link("The topic: \"#{@topic.topic_name}\" has been successfully deleted. ")
    else
      flash[:error] = "The topic could not be deleted."
    end

    # if this assignment has staggered deadlines then destroy the dependencies as well
    if Assignment.find(params[:assignment_id])['staggered_deadline'] == true
      dependencies = TopicDependency.where(topic_id: params[:id])
      dependencies.each(&:destroy) unless dependencies.nil?
    end
    # changing the redirection url to topics tab in edit assignment view.
    redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-5"
  end

  # prepares the page. shows the form which can be used to enter new values for the different properties of an assignment
  def edit
    @topic = SignUpTopic.find(params[:id])
  end

  # updates the database tables to reflect the new values for the assignment. Used in conjuntion with edit
  def update
    @topic = SignUpTopic.find(params[:id])

    if @topic
      @topic.topic_identifier = params[:topic][:topic_identifier]

      update_max_choosers @topic

      # update tables
      @topic.category = params[:topic][:category]
      @topic.topic_name = params[:topic][:topic_name]
      @topic.micropayment = params[:topic][:micropayment]
      @topic.save
      undo_link("The topic: \"#{@topic.topic_name}\" has been successfully updated. ")
    else
      flash[:error] = "The topic could not be updated."
      end
    # changing the redirection url to topics tab in edit assignment view.
    redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-5"
  end

  def assign_topic # renders a view for a team to be added
    @topic = SignUpTopic.find(params[:id])
    @assignment = Assignment.find(params[:assignment_id])
  end

  def remove_topic # renders a view for the team to be removed
    @topic = SignUpTopic.find(params[:id])
    @assignment = Assignment.find(params[:assignment_id])
  end

  def remove_team # method for remove the topic assigned to the team
    @topic = SignUpTopic.find(params[:id]) #Find all the details about the topic
    @assignment = Assignment.find(params[:assignment_id]) # Find all the details about the assignment
    @user = User.find_by name: params[:user][:name] # Find user

    if @user.blank?
      flash[:error] = "User does not exist"
      redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
    else
      @team = TeamsUser.find_by_sql("select T1.team_id from teams_users T1, teams T2 where T1.user_id = "+ @user.id.to_s+" AND T1.team_id = T2.id AND T2.parent_id = "+ @assignment.id.to_s) # find a team associated with this user having particular assignment and topic
      @isTopicTaken = SignedUpTeam.find_by_sql("select * from signed_up_teams where topic_id = "+ @topic.id.to_s) # List of all teams having the same topic

      if(@isTopicTaken.any?)
        if(@team.any?)
          @userTeam = SignedUpTeam.find_by_sql("select * from signed_up_teams where team_id = "+ @team[0].team_id.to_s) # Previously assigned topic
          if(@userTeam.any? and @userTeam[0].topic_id == @topic.id)
            @userTeam[0].destroy
            @isTopicTakenNow = SignedUpTeam.find_by_sql("select * from signed_up_teams where topic_id = "+ @topic.id.to_s + " AND is_waitlisted = 1")
            if(@isTopicTakenNow.any?)
              @isTopicTakenNow[0].update(is_waitlisted: 0)
            end
            flash[:success] = "The team has been successfully removed"
          else
            flash[:error] = "This team does not have this topic."
          end
        else
          flash[:error] = "User does not have a team for this assignment."
        end
      else
        flash[:error] = "This topic has not been assigned."
      end
      redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
    end
  end


  def update_team # method for add the topic to the team
    @topic = SignUpTopic.find(params[:id]) #Find all the details about the topic
    @assignment = Assignment.find(params[:assignment_id]) # Find all the details about the assignment
    @user = User.find_by name: params[:user][:name] # Find user

    if @user.blank?
      flash[:error] = "User does not exist"
      redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
    else
      @team = TeamsUser.find_by_sql("select T1.team_id from teams_users T1, teams T2 where T1.user_id = "+ @user.id.to_s+" AND T1.team_id = T2.id AND T2.parent_id = "+ @assignment.id.to_s)
      @isTopicTaken = SignedUpTeam.find_by_sql("select * from signed_up_teams where topic_id = "+ @topic.id.to_s)
      @disp_flag = 0

      if(@team.any?)
        @userTeam = SignedUpTeam.find_by_sql("select * from signed_up_teams where team_id = "+ @team[0].team_id.to_s)
        if(@isTopicTaken.any?)
          if(@userTeam.any?)
            @oldTopic = @userTeam[0].topic_id;
            @isTopicTaken.each do |f|
              if f.team_id == @team[0].team_id
                @disp_flag = 1
                flash[:error] = "The topic is already assigned to the same team."
                redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
              end
            end
            if @disp_flag != 1
              @userTeam[0].update(topic_id: @topic.id)
              puts @topic.max_choosers
              if (@isTopicTaken.size >= @topic.max_choosers)
                @userTeam[0].update(is_waitlisted: 1)
                flash[:success] = "Team is in the waitlist now"
              else
                @userTeam[0].update(is_waitlisted: 0)
                flash[:success] = "The topic has been assigned to the team"
              end
              @oldTopicTeams = SignedUpTeam.find_by_sql("select * from signed_up_teams where topic_id= "+ @oldTopic.to_s+" and is_waitlisted=1")
              if(@oldTopicTeams.any?)
                @oldTopicTeams[0].update(is_waitlisted: 0)
              end
              redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
            end

          else #@userTeam.any
            @sign_up = SignedUpTeam.new
            @sign_up.topic_id = @topic.id
            @sign_up.team_id = @team[0].team_id
            if (@isTopicTaken.size >= @topic.max_choosers)
              @sign_up.is_waitlisted = 1
            else
              @sign_up.is_waitlisted = 0
            end
            @sign_up.preference_priority_number =0
            if @sign_up.save
              flash[:success] = "The topic has been assigned to the team"
            else
              flash[:error] = "The topic could not be assigned."
            end
            redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
          end

        else #isTopicTaken
          if @userTeam.any?
            @oldTopic = @userTeam[0].topic_id;
            @userTeam[0].update(topic_id: @topic.id)
            @userTeam[0].update(is_waitlisted: 0)
            @oldTopicTeams = SignedUpTeam.find_by_sql("select * from signed_up_teams where topic_id= "+ @oldTopic.to_s+" and is_waitlisted=1")
            if(@oldTopicTeams.any?)
              @oldTopicTeams[0].update(is_waitlisted: 0)
            end
            redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
          else
            @sign_up = SignedUpTeam.new
            @sign_up.topic_id = @topic.id
            @sign_up.team_id = @team[0].team_id
            @sign_up.is_waitlisted = 0
            @sign_up.preference_priority_number =0
            if @sign_up.save
              flash[:success] = "The topic has been assigned to the team"
            else
              flash[:error] = "The topic could not be assigned."
            end
            redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
          end
        end
      else
        flash[:error] = "This user does not have a team"
        redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-2"
      end
    end
  end


  # This displays a page that lists all the available topics for an assignment.
  # Contains links that let an admin or Instr@topic = SignUpTopic.find(params[:id])uctor edit, delete, view enrolled/waitlisted members for each topic
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
    @sign_up_topics = SignUpTopic.where(['assignment_id = ?', assignment_id])
    @slots_filled = SignUpTopic.find_slots_filled(assignment_id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(assignment_id)

    @assignment = Assignment.find(assignment_id)
    # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    # Though called participants, @participants are actually records in signed_up_teams table, which
    # is a mapping table between teams and topics (waitlisted recored are also counted)
    @participants = SignedUpTeam.find_team_participants(assignment_id)
  end

  def set_values_for_new_topic
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
  def redirect_to_sign_up(assignment_id)
    assignment = Assignment.find(assignment_id)
    (assignment.staggered_deadline == true) ? (redirect_to action: 'add_signup_topics_staggered', id: assignment_id) : (redirect_to action: 'add_signup_topics', id: assignment_id)
  end

  # simple function that redirects to assignment->edit->topic panel to display /add_signup_topics or the /add_signup_topics_staggered page
  # staggered means that different topics can have different deadlines.
  def redirect_to_assignment_edit(assignment_id)
    assignment = Assignment.find(assignment_id)
    redirect_to controller: 'assignments', action: 'edit', id: assignment_id
  end

  def list
    @assignment_id = params[:assignment_id].to_i
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment_id, private_to: nil)
    @num_of_topics = @sign_up_topics.size
    @slots_filled = SignUpTopic.find_slots_filled(params[:assignment_id])
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(params[:assignment_id])
    @show_actions = true
    @priority = 0
    assignment = Assignment.find(@assignment_id)
    @signup_topic_deadline = assignment.due_dates.find_by_deadline_type_id(7)
    @drop_topic_deadline = assignment.due_dates.find_by_deadline_type_id(6)
    @student_bids = Bid.where(user_id: session[:user].id)

    unless assignment.due_dates.find_by_deadline_type_id(1).nil?
      if !assignment.staggered_deadline? and assignment.due_dates.find_by_deadline_type_id(1).due_at < Time.now
        @show_actions = false
      end

      # Find whether the user has signed up for any topics; if so the user won't be able to
      # sign up again unless the former was a waitlisted topic
      # if team assignment, then team id needs to be passed as parameter else the user's id
      users_team = SignedUpTeam.find_team_users(@assignment_id, session[:user].id)

      @selected_topics = if users_team.empty?
                           nil
                         else
                           # TODO: fix this; cant use 0
                           SignedUpTeam.find_user_signup_topics(@assignment_id, users_team[0].t_id)
                         end

    end
  end

  # this function is used to delete a previous signup
  def delete_signup
    assignment = Assignment.find(params[:assignment_id])
    participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', session[:user].id, params[:assignment_id]).first
    drop_topic_deadline = assignment.due_dates.find_by_deadline_type_id(6)
    # A student who has already submitted work should not be allowed to drop his/her topic!
    # (A student/team has submitted if participant directory_num is non-null or submitted_hyperlinks is non-null.)
    # If there is no drop topic deadline, student can drop topic at any time (if all the submissions are deleted)
    # If there is a drop topic deadline, student cannot drop topic after this deadline.
    if !participant.team.submitted_files.empty? or !participant.team.hyperlinks.empty?
      flash[:error] = "You have already submitted your work, so you are not allowed to drop your topic."
    elsif !drop_topic_deadline.nil? and Time.now > drop_topic_deadline.due_at
      flash[:error] = "You cannot drop your topic after drop topic deadline!"
    else
      delete_signup_for_topic(params[:assignment_id], params[:id])
      flash[:success] = "You have successfully dropped your topic!"
    end
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end

  def delete_signup_for_topic(assignment_id, topic_id)
    @user_id = session[:user].id
    SignUpTopic.reassign_topic(@user_id, assignment_id, topic_id)
  end

  def sign_up
    # find the assignment to which user is signing up
    @assignment = Assignment.find(params[:assignment_id])
    @user_id = session[:user].id
    # Always use team_id ACS
    # s = Signupsheet.new
    # Team lazy initialization: check whether the user already has a team for this assignment
    unless SignUpSheet.signup_team(@assignment.id, @user_id, params[:id])
      flash[:error] = "You've already signed up for a topic!"
    end
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end

  def set_priority
    @user_id = session[:user].id
    # users_team = SignedUpTeam.find_team_users(params[:assignment_id].to_s, @user_id)
    # check = SignedUpTeam.find_by_sql(["SELECT su.* FROM signed_up_teams su , sign_up_topics st WHERE su.topic_id = st.id AND st.assignment_id = ? AND su.team_id = ? AND su.preference_priority_number = ?", params[:assignment_id].to_s, users_team[0].t_id, params[:priority].to_s])
    # if check.empty?
    #   signUp = SignedUpTeam.where(topic_id: params[:id], team_id: users_team[0].t_id).first
    #   # signUp.preference_priority_number = params[:priority].to_s
    #   if params[:priority].to_s.to_f > 0
    #     signUp.update_attribute('preference_priority_number', params[:priority].to_s)
    #   else
    #     flash[:error] = "That is an invalid priority."
    #   end
    # end
    check = Bid.where(user_id: @user_id, topic_id: params[:id])
    if !Bid.where(user_id: @user_id, priority: params[:priority]).empty?
      flash[:error] = "You have already selected this priority"
    elsif check.empty?
      Bid.create(topic_id: params[:id], user_id: @user_id, priority: params[:priority])
    else
      check.first.update(priority: params[:priority])
    end
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end

  # If the instructor needs to explicitly change the start/due dates of the topics
  # This is true in case of a staggered deadline type assignment. Individual deadlines can
  # be set on a per topic and per round basis
  def save_topic_deadlines
    assignment = Assignment.find(params[:assignment_id])
    @assignment_submission_due_dates = assignment.due_dates.select {|due_date| due_date.deadline_type_id == 1 }
    @assignment_review_due_dates = assignment.due_dates.select {|due_date| due_date.deadline_type_id == 2 }
    due_dates = params[:due_date]
    topics = SignUpTopic.where(assignment_id: params[:assignment_id])
    review_rounds = assignment.num_review_rounds
    topics.each_with_index do |topic, index|
      for i in 1..review_rounds
        @topic_submission_due_date = due_dates[topics[index].id.to_s + '_submission_' + i.to_s + '_due_date']
        @topic_review_due_date = due_dates[topics[index].id.to_s + '_review_' + i.to_s + '_due_date']
        @assignment_submission_due_date = DateTime.parse(@assignment_submission_due_dates[i - 1].due_at.to_s).strftime("%Y-%m-%d %H:%M")
        @assignment_review_due_date = DateTime.parse(@assignment_review_due_dates[i - 1].due_at.to_s).strftime("%Y-%m-%d %H:%M")
        %w(submission review).each do |deadline_type|
          deadline_type_id = DeadlineType.find_by_name(deadline_type).id
          next if instance_variable_get('@topic_' + deadline_type + '_due_date') == instance_variable_get('@assignment_' + deadline_type + '_due_date')
          topic_due_date = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_id, round: i).first rescue nil
          if topic_due_date.nil? # create a new record
            TopicDueDate.create(
              due_at:                      instance_variable_get('@topic_' + deadline_type + '_due_date'),
              deadline_type_id:            DeadlineType.find_by_name(deadline_type).id,
              parent_id:                   topic.id,
              submission_allowed_id:       instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].submission_allowed_id,
              review_allowed_id:           instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_allowed_id,
              review_of_review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_of_review_allowed_id, 
              round:                       i,
              flag:                        instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].flag,
              threshold:                   instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].threshold,
              delayed_job_id:              instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].delayed_job_id,
              deadline_name:               instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].deadline_name,
              description_url:             instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].description_url,
              quiz_allowed_id:             instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].quiz_allowed_id,
              teammate_review_allowed_id:  instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].teammate_review_allowed_id,
              type:                       'TopicDueDate'
            )
          else # update an existed record
            topic_due_date.update_attributes(
              due_at:                      instance_variable_get('@topic_' + deadline_type + '_due_date'),
              submission_allowed_id:       instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].submission_allowed_id,
              review_allowed_id:           instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_allowed_id,
              review_of_review_allowed_id: instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].review_of_review_allowed_id, 
              quiz_allowed_id:             instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].quiz_allowed_id,
              teammate_review_allowed_id:  instance_variable_get('@assignment_' + deadline_type + '_due_dates')[i - 1].teammate_review_allowed_id
            )
          end
        end
      end
    end
    redirect_to_assignment_edit(params[:assignment_id])
  end

  # This method is called when a student click on the trumpet icon. So this is a bad method name. --Yang
  def show_team
    if !(assignment = Assignment.find(params[:assignment_id])).nil? and !(topic = SignUpTopic.find(params[:id])).nil?
      @results = ad_info(assignment.id, topic.id)
      @results.each do |result|
        result.keys.each do |key|
          @current_team_name = result[key] if key.equal? :name
        end
      end
      @results.each do |result|
        @team_members = ""
        TeamsUser.where(team_id: result[:team_id]).each do |teamuser|
          @team_members += User.find(teamuser.user_id).name + " "
        end
      end
      # @team_members = find_team_members(topic)
    end
  end

  def switch_original_topic_to_approved_suggested_topic
    team_id = TeamsUser.team_id(params[:assignment_id].to_i, session[:user].id)
    original_topic_id = SignedUpTeam.topic_id(params[:assignment_id].to_i, session[:user].id)
    SignUpTopic.find(params[:id]).update_attribute('private_to', nil) if SignUpTopic.exists?(params[:id])
    SignedUpTeam.where(team_id: team_id, is_waitlisted: 0).first.update_attribute('topic_id', params[:id].to_i) if SignedUpTeam.exists?(team_id: team_id, is_waitlisted: 0)
    # check the waitlist of original topic. Let the first waitlisted team hold the topic, if exists.
    waitlisted_teams = SignedUpTeam.where(topic_id: original_topic_id, is_waitlisted: 1)
    unless waitlisted_teams.blank?
      waitlisted_first_team_first_user_id = TeamsUser.where(team_id: waitlisted_teams.first.team_id).first.user_id
      SignUpSheet.signup_team(params[:assignment_id].to_i, waitlisted_first_team_first_user_id, original_topic_id)
    end
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end

  def publish_approved_suggested_topic
    SignUpTopic.find(params[:id]).update_attribute('private_to', nil) if SignUpTopic.exists?(params[:id])
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end

  private

  # authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.where('user_id = ? and parent_id = ?', session[:user].id, params[:assignment_id]).first
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reader' or authorization == 'submitter' or authorization == 'reviewer'
      return false
    else
      return true
    end
  end

  def setup_new_topic
    set_values_for_new_topic

    if @assignment.is_microtask?
      @sign_up_topic.micropayment = params[:topic][:micropayment]
    end

    if @assignment.staggered_deadline?
      topic_set = []
      topic = @sign_up_topic.id
    end

    if @sign_up_topic.save
      undo_link "The topic: \"#{@sign_up_topic.topic_name}\" has been created successfully. "
      # changing the redirection url to topics tab in edit assignment view.
      redirect_to edit_assignment_path(@sign_up_topic.assignment_id) + "#tabs-5"
    else
      render action: 'new', id: params[:id]
    end
  end

  def update_existing_topic(topic)
    topic.topic_identifier = params[:topic][:topic_identifier]

    update_max_choosers topic

    topic.category = params[:topic][:category]
    # topic.assignment_id = params[:id]
    topic.save
    redirect_to_sign_up params[:id]
  end

  def update_max_choosers(topic)
    # While saving the max choosers you should be careful; if there are users who have signed up for this particular
    # topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
    # there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
    # it.
    if SignedUpTeam.find_by_topic_id(topic.id).nil? || topic.max_choosers == params[:topic][:max_choosers]
      topic.max_choosers = params[:topic][:max_choosers]
    else
      if topic.max_choosers.to_i < params[:topic][:max_choosers].to_i
        topic.update_waitlisted_users params[:topic][:max_choosers]
        topic.max_choosers = params[:topic][:max_choosers]
      else
        flash[:error] = 'The value of the maximum number of choosers can only be increased! No change has been made to maximum choosers.'
      end
    end
  end

  # get info related to the ad for partners so that it can be displayed when an assignment_participant
  # clicks to see ads related to a topic
  def ad_info(_assignment_id, topic_id)
    # List that contains individual result object
    @result_list = []
    # Get the results
    @results = SignedUpTeam.where("topic_id = ?", topic_id.to_s)
    # Iterate through the results of the query and get the required attributes
    @results.each do |result|
      team = result.team
      topic = result.topic
      resultMap = {}
      resultMap[:team_id] = team.id
      resultMap[:comments_for_advertisement] = team.comments_for_advertisement
      resultMap[:name] = team.name
      resultMap[:assignment_id] = topic.assignment_id
      resultMap[:advertise_for_partner] = team.advertise_for_partner

      # Append to the list
      @result_list.append(resultMap)
    end
    @result_list
  end
end
