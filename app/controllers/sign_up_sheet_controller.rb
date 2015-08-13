#contains all functions related to management of the signup sheet for an assignment
#functions to add new topics to an assignment, edit properties of a particular topic, delete a topic, etc
#are included here

#A point to be taken into consideration is that :id (except when explicitly stated) here means topic id and not assignment id
#(this is referenced as :assignment id in the params has)
#The way it works is that assignments have their own id's, so do topics. A topic has a foreign key dependecy on the assignment_id
#Hence each topic has a field called assignment_id which points which can be used to identify the assignment that this topic belongs
#to

class SignUpSheetController < ApplicationController
  require 'rgl/adjacency'
  require 'rgl/dot'
  require 'rgl/topsort'

  def action_allowed?
    case params[:action]
    when 'sign_up', 'delete_signup', 'list', 'show_team', 'switch_original_topic_to_approved_suggested_topic', 'publish_approved_suggested_topic'
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

  #Includes functions for team management. Refer /app/helpers/ManageTeamHelper
  include ManageTeamHelper
  #Includes functions for Dead line management. Refer /app/helpers/DeadLineHelper
  include DeadlineHelper

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:destroy, :create, :update],
    :redirect_to => {:action => :list}

  # Prepares the form for adding a new topic. Used in conjunction with create
  def new
    @id = params[:id]
    @sign_up_topic = SignUpTopic.new
    @sign_up_topic.assignment = Assignment.find(params[:id])
    @topic = @sign_up_topic
  end

  #This method is used to create signup topics
  #In this code params[:id] is the assignment id and not topic id. The intuition is
  #that assignment id will virtually be the signup sheet id as well as we have assumed
  #that every assignment will have only one signup sheet
  def create
    topic = SignUpTopic.where(topic_name: params[:topic][:topic_name], assignment_id:  params[:id]).first

    #if the topic already exists then update
    if topic != nil
      topic.topic_identifier = params[:topic][:topic_identifier]

      #While saving the max choosers you should be careful; if there are users who have signed up for this particular
      #topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
      #there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
      #it.
      if SignedUpTeam.find_by_topic_id(topic.id).nil? || topic.max_choosers == params[:topic][:max_choosers]
        topic.max_choosers = params[:topic][:max_choosers]
      else
        if topic.max_choosers.to_i < params[:topic][:max_choosers].to_i
          topic.update_waitlisted_users(params[:topic][:max_choosers])
          topic.max_choosers = params[:topic][:max_choosers]
        else
          flash[:error] = 'Value of maximum choosers can only be increased! No change has been made to max choosers.'
        end
      end

      topic.category = params[:topic][:category]
      #topic.assignment_id = params[:id]
      topic.save
      redirect_to_sign_up(params[:id])
    else
        set_values_for_new_topic

        if @assignment.is_microtask?
          @sign_up_topic.micropayment = params[:topic][:micropayment]
        end

        if @assignment.staggered_deadline?
          topic_set = Array.new
          topic = @sign_up_topic.id
        end

        if @sign_up_topic.save
          undo_link("Topic: \"#{@sign_up_topic.topic_name}\" has been created successfully. ")
          #changing the redirection url to topics tab in edit assignment view.
          redirect_to edit_assignment_path(@sign_up_topic.assignment_id) + "#tabs-5"
        else
          render :action => 'new', :id => params[:id]
        end
      end
    end

    #This method is used to delete signup topics
    #Renaming delete method to destroy for rails 4 compatible
    def destroy
      @topic = SignUpTopic.find(params[:id])
      if @topic
        @topic.destroy
        undo_link("Topic: \"#{@topic.topic_name}\" has been deleted successfully. ")
      else
        flash[:error] = "Topic could not be deleted"
      end

      #if this assignment has staggered deadlines then destroy the dependencies as well
      if Assignment.find(params[:assignment_id])['staggered_deadline'] == true
        dependencies = TopicDependency.where(topic_id: params[:id])
        unless dependencies.nil?
          dependencies.each { |dependency| dependency.destroy }
        end
      end
      #changing the redirection url to topics tab in edit assignment view.
      redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-5"
    end

    #prepares the page. shows the form which can be used to enter new values for the different properties of an assignment
    def edit
      @topic = SignUpTopic.find(params[:id])
    end

    #updates the database tables to reflect the new values for the assignment. Used in conjuntion with edit
    def update
      @topic = SignUpTopic.find(params[:id])

      if @topic
        @topic.topic_identifier = params[:topic][:topic_identifier]

        #While saving the max choosers you should be careful; if there are users who have signed up for this particular
        #topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
        #there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
        #it.
        if SignedUpTeam.find_by_topic_id(@topic.id).nil? || @topic.max_choosers == params[:topic][:max_choosers]
          @topic.max_choosers = params[:topic][:max_choosers]
        else
          if @topic.max_choosers.to_i < params[:topic][:max_choosers].to_i
            @topic.update_waitlisted_users(params[:topic][:max_choosers])
            @topic.max_choosers = params[:topic][:max_choosers]
          else
            flash[:error] = 'Value of maximum choosers can only be increased! No change has been made to max choosers.'
          end
        end

        #update tables
        @topic.category = params[:topic][:category]
        @topic.topic_name = params[:topic][:topic_name]
        @topic.micropayment = params[:topic][:micropayment]
        @topic.save
        undo_link("Topic: \"#{@topic.topic_name}\" has been updated successfully. ")
        else
          flash[:error] = "Topic could not be updated"
        end
        #changing the redirection url to topics tab in edit assignment view.
        redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-5"
      end


      #This displays a page that lists all the available topics for an assignment.
      #Contains links that let an admin or Instructor edit, delete, view enrolled/waitlisted members for each topic
      #Also contains links to delete topics and modify the deadlines for individual topics. Staggered means that different topics
      #can have different deadlines.
      def add_signup_topic
        load_add_signup_topics(params[:id])
        SignUpSheet.add_signup_topic(params[:id])
      end

      def add_signup_topics_staggered
        add_signup_topic
      end

      #similar to the above function except that all the topics and review/submission rounds have the similar deadlines
      def add_signup_topics
        load_add_signup_topics(params[:id])
      end

      #Seems like this function is similar to the above function> we are not quite sure what publishing rights mean. Seems like
      #the values for the last column in http://expertiza.ncsu.edu/student_task/list are sourced from here
      def view_publishing_rights
        load_add_signup_topics(params[:id])
      end

      #retrieves all the data associated with the given assignment. Includes all topics,
      def load_add_signup_topics(assignment_id)
        @id = assignment_id
        @sign_up_topics = SignUpTopic.where( ['assignment_id = ?', assignment_id])
        @slots_filled = SignUpTopic.find_slots_filled(assignment_id)
        @slots_waitlisted = SignUpTopic.find_slots_waitlisted(assignment_id)

        @assignment = Assignment.find(assignment_id)
        #ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        #Though called participants, @participants are actually records in signed_up_teams table, which
        #is a mapping table between teams and topics (waitlisted recored are also counted)
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

      #simple function that redirects to assignment->edit->topic panel to display /add_signup_topics or the /add_signup_topics_staggered page
      #staggered means that different topics can have different deadlines.
      def redirect_to_assignment_edit(assignment_id)
        assignment = Assignment.find(assignment_id)
        redirect_to :controller => 'assignments', :action => 'edit', :id => assignment_id
      end

  def list
    @assignment_id = params[:assignment_id].to_i
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment_id, private_to: nil)
    @slots_filled = SignUpTopic.find_slots_filled(params[:assignment_id])
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(params[:assignment_id])
    @show_actions = true
    @priority = 0
    assignment=Assignment.find(@assignment_id)
    @signup_topic_deadline = assignment.due_dates.find_by_deadline_type_id(7)
    @drop_topic_deadline = assignment.due_dates.find_by_deadline_type_id(6)

    if assignment.due_dates.find_by_deadline_type_id(1)!= nil
      unless !(assignment.staggered_deadline? and assignment.due_dates.find_by_deadline_type_id(1).due_at < Time.now)
        @show_actions = false
      end

      #Find whether the user has signed up for any topics; if so the user won't be able to
      #sign up again unless the former was a waitlisted topic
      #if team assignment, then team id needs to be passed as parameter else the user's id
      users_team = SignedUpTeam.find_team_users(@assignment_id, (session[:user].id))

      if users_team.size == 0
        @selected_topics = nil
      else
        #TODO: fix this; cant use 0
        @selected_topics = SignUpSheetController.other_confirmed_topic_for_user(@assignment_id, users_team[0].t_id)
      end

      SignUpTopic.remove_team(users_team, @assignment_id)

    end
  end


        #this function is used to delete a previous signup
  def delete_signup
    assignment = Assignment.find(params[:assignment_id])
    participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', session[:user].id, params[:assignment_id]).first
    drop_topic_deadline = assignment.due_dates.find_by_deadline_type_id(6)
    #A student who has already submitted work should not be allowed to drop his/her topic! 
    #(A student/team has submitted if participant directory_num is non-null or submitted_hyperlinks is non-null.)
    #If there is no drop topic deadline, student can drop topic at any time (if all the submissions are deleted)
    #If there is a drop topic deadline, student cannot drop topic after this deadline.
    if !participant.directory_num.nil? or !participant.hyperlinks.blank?
      flash[:error] = "You have submitted your work, so you are not allowed to drop your topic."
    elsif !drop_topic_deadline.nil? and Time.now > drop_topic_deadline.due_at
      flash[:error] = "You cannot drop your topic after drop topic deadline!"
    else
      delete_signup_for_topic(params[:assignment_id], params[:id])
      flash[:success] = "You have dropped your topic successfully!"
    end
    redirect_to :action => 'list', :assignment_id => params[:assignment_id]
  end

  def delete_signup_for_topic(assignment_id, topic_id)
    @user_id = session[:user].id
    SignUpTopic.reassign_topic(@user_id, assignment_id, topic_id)
  end

  def sign_up

    #find the assignment to which user is signing up
    @assignment = Assignment.find(params[:assignment_id])
    @user_id = session[:user].id
    #Always use team_id ACS
    #s = Signupsheet.new
    #Team lazy initialization: check whether the user already has a team for this assignment
    unless SignUpSheet.signup_team(@assignment.id, @user_id, params[:id]) then
	flash[:error] = "You've already signed up for a topic!"
    end
    redirect_to :action => 'list', :assignment_id => params[:assignment_id]
  end

        # When using this method when creating fields, update race conditions by using db transactions
  def slotAvailable?(topic_id)
    SignUpTopic.slotAvailable?(topic_id)
  end

  def self.other_confirmed_topic_for_user(assignment_id, team_id)

    user_signup = SignedUpTeam.find_user_signup_topics(assignment_id, team_id)
    user_signup
  end

  def set_priority
    @user_id = session[:user].id
    users_team = SignedUpTeam.find_team_users(params[:assignment_id].to_s, @user_id)
    check = SignedUpTeam.find_by_sql(["SELECT su.* FROM signed_up_teams su , sign_up_topics st WHERE su.topic_id = st.id AND st.assignment_id = ? AND su.team_id = ? AND su.preference_priority_number = ?", params[:assignment_id].to_s, users_team[0].t_id, params[:priority].to_s])
    if check.size == 0
      signUp = SignedUpTeam.where(topic_id: params[:id], team_id: users_team[0].t_id).first
      #signUp.preference_priority_number = params[:priority].to_s
      if params[:priority].to_s.to_f > 0
        signUp.update_attribute('preference_priority_number', params[:priority].to_s)
      else
        flash[:error] = "Invalid priority"
      end
    end
    redirect_to :action => 'list', :id => params[:assignment_id]
  end

        #this function is used to prevent injection attacks.  A topic *dependent* on another topic cannot be
        # attempted until the other topic has been completed..
  def save_topic_dependencies
    # Prevent injection attacks - we're using this in a system() call later
    params[:assignment_id] = params[:assignment_id].to_i.to_s

    topics = SignUpTopic.where(assignment_id: params[:assignment_id])
    topics = topics.collect { |topic|
      #if there is no dependency for a topic then there wont be a post for that tag.
      #if this happens store the dependency as "0"
      !(params['topic_dependencies_' + topic.id.to_s].nil?) ? ([topic.id, params['topic_dependencies_' + topic.id.to_s][:dependent_on]]) : ([topic.id, ["0"]])
    }
    # Save the dependency in the topic dependency table
    TopicDependency.save_dependency(topics)

    node = 'id'
    dg = build_dependency_graph(topics, node)

    if dg.acyclic?
      #This method produces sets of vertexes which should have common start time/deadlines
      set_of_topics = create_common_start_time_topics(dg)
      set_start_due_date(params[:assignment_id], set_of_topics)
      @top_sort = dg.topsort_iterator.to_a
    else
      flash[:error] = "There may be one or more cycles in the dependencies. Please correct them"
    end

    node = 'topic_name'
    dg = build_dependency_graph(topics, node) # rebuild with new node name

    graph_output_path = 'public/assets/staggered_deadline_assignment_graph'
    FileUtils::mkdir_p graph_output_path
    dg.write_to_graphic_file('jpg', "#{graph_output_path}/graph_#{params[:assignment_id]}")

    #execute linux bash script, convert .dot to jpg
    system("dot -Tjpg #{graph_output_path}/graph_#{params[:assignment_id]}.dot -o #{graph_output_path}/graph_#{params[:assignment_id]}.jpg")

    redirect_to_assignment_edit(params[:assignment_id])
  end


        #If the instructor needs to explicitly change the start/due dates of the topics
        #This is true in case of a staggered deadline type assignment. Individual deadlines can
        # be set on a per topic  and per round basis
  def save_topic_deadlines
    #session[:duedates] stores all original duedates info
    #due_dates stores staggered duedates
    due_dates = params[:due_date]

    topics = SignUpTopic.where(assignment_id: params[:assignment_id])
    review_rounds = Assignment.find(params[:assignment_id]).get_review_rounds
    # j represents the review rounds
    j = 0
    topics.each { |topic|
      for i in 1..review_rounds
        topic_deadline_type_subm = DeadlineType.find_by_name('submission').id
        topic_deadline_subm = TopicDeadline.where(topic_id: session[:duedates][j]['id'].to_i, deadline_type_id: topic_deadline_type_subm, round: i).first

        topic_deadline_subm.update_attributes({'due_at' => due_dates[session[:duedates][j]['id'].to_s + '_submission_' + i.to_s + '_due_date']})
        flash[:error] = "Please enter a valid " + (i > 1 ? "Resubmission deadline " + (i-1).to_s : "Submission deadline") if topic_deadline_subm.errors.length > 0

        topic_deadline_type_rev = DeadlineType.find_by_name('review').id
        topic_deadline_rev = TopicDeadline.where(topic_id: session[:duedates][j]['id'].to_i, deadline_type_id: topic_deadline_type_rev, round: i).first
        topic_deadline_rev.update_attributes({'due_at' => due_dates[session[:duedates][j]['id'].to_s + '_review_' + i.to_s + '_due_date']})
        flash[:error] = "Please enter a valid Review deadline " + (i > 1 ? (i-1).to_s : "") if topic_deadline_rev.errors.length > 0
      end

      topic_deadline_subm = TopicDeadline.where(topic_id: session[:duedates][j]['id'], deadline_type_id: DeadlineType.find_by_name('metareview').id).first
      topic_deadline_subm.update_attributes({'due_at' => due_dates[session[:duedates][j]['id'].to_s + '_submission_' + (review_rounds+1).to_s + '_due_date']})
      flash[:error] = "Please enter a valid Meta review deadline" if topic_deadline_subm.errors.length > 0
      j = j + 1
    }

    redirect_to_assignment_edit(params[:assignment_id])
  end

        #used by save_topic_dependencies. The dependency graph is a partial ordering of topics ... some topics need to be done
        # before others can be attempted.
  def build_dependency_graph(topics, node)
    SignUpSheet.create_dependency_graph(topics, node)
  end

        #used by save_topic_dependencies. Do not know how this works
  def create_common_start_time_topics(dg)
    dg_reverse = dg.clone.reverse()
    set_of_topics = Array.new

    until dg_reverse.empty?
      i = 0
      temp_vertex_array = Array.new
      dg_reverse.each_vertex { |vertex|
        if dg_reverse.out_degree(vertex) == 0
          temp_vertex_array.push(vertex)
        end
      }
      #this cannot go inside the if statement above
      temp_vertex_array.each { |vertex|
        dg_reverse.remove_vertex(vertex)
      }
      set_of_topics.insert(i, temp_vertex_array)
      i = i + 1
    end
    set_of_topics
  end

  def set_start_due_date(assignment_id, set_of_topics)
    DeadlineHelper.set_start_due_date(assignment_id, set_of_topics)
  end

  #gets team_details to show it on team_details view for a given assignment
  def show_team
    if !(assignment = Assignment.find(params[:assignment_id])).nil? and !(topic = SignUpTopic.find(params[:id])).nil?
      @results =ad_info(assignment.id, topic.id)
      @results.each do |result|
        result.attributes().each do |attr|
          if attr[0].equal? "name"
            @current_team_name = attr[1]
          end
        end
      end
      @results.each { |result|
        @team_members = ""
        TeamsUser.where(team_id: result[:team_id]).each { |teamuser|
          @team_members+=User.find(teamuser.user_id).name+" "
        }
      }
      #@team_members = find_team_members(topic)
    end
  end

        # get info related to the ad for partners so that it can be displayed when an assignment_participant
        # clicks to see ads related to a topic
  def ad_info(assignment_id, topic_id)
    query = "select t.id as team_id,t.comments_for_advertisement,t.name,su.assignment_id, t.advertise_for_partner from teams t, signed_up_teams s,sign_up_topics su "+
        "where s.topic_id='"+topic_id.to_s+"' and s.team_id=t.id and s.topic_id = su.id;    "
    SignUpTopic.find_by_sql(query)
  end

  def add_default_microtask
    assignment_id = params[:id]
    @sign_up_topic = SignUpTopic.new
    @sign_up_topic.topic_identifier = 'MT1'
    @sign_up_topic.topic_name = 'Microtask Topic'
    @sign_up_topic.max_choosers = '0'
    @sign_up_topic.micropayment = 0
    @sign_up_topic.assignment_id = assignment_id

    @assignment = Assignment.find(params[:id])

    if @assignment.staggered_deadline?
      topic_set = Array.new
      topic = @sign_up_topic.id
    end

    if @sign_up_topic.save

      flash[:notice] = 'Default Microtask topic was created - please update.'
      redirect_to_sign_up(assignment_id)
    else
      render :action => 'new', :id => assignment_id
    end
  end

  def switch_original_topic_to_approved_suggested_topic
    team_id = TeamsUser.team_id(params[:assignment_id].to_i, session[:user].id)
    original_topic_id = SignedUpTeam.topic_id(params[:assignment_id].to_i, session[:user].id)
    SignUpTopic.find(params[:id]).update_attribute('private_to', nil) if SignUpTopic.exists?(params[:id]) 
    SignedUpTeam.where(team_id: team_id, is_waitlisted: 0).first.update_attribute('topic_id', params[:id].to_i) if SignedUpTeam.exists?(team_id: team_id, is_waitlisted: 0)
    #check the waitlist of original topic. Let the first waitlisted team hold the topic, if exists.
    waitlisted_teams = SignedUpTeam.where(topic_id: original_topic_id, is_waitlisted:1)
    if !waitlisted_teams.blank?
      waitlisted_first_team_first_user_id = TeamsUser.where(team_id: waitlisted_teams.first.team_id).first.user_id
      SignUpSheet.signup_team(params[:assignment_id].to_i, waitlisted_first_team_first_user_id, original_topic_id)
    end
    redirect_to :action => 'list', :assignment_id => params[:assignment_id]
  end

  def publish_approved_suggested_topic
    SignUpTopic.find(params[:id]).update_attribute('private_to', nil) if SignUpTopic.exists?(params[:id])
    redirect_to :action => 'list', :assignment_id => params[:assignment_id]
  end

  private
  #authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.where('user_id = ? and parent_id = ?', session[:user].id, params[:assignment_id]).first
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reader' or authorization == 'submitter' or authorization == 'reviewer'
      return false
    else
      return true
    end
  end
end
