class SignUpSheetController < ApplicationController
  require 'rgl/adjacency'
  require 'rgl/dot'
  require 'graph/graphviz_dot'
  require 'rgl/topsort'


  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:destroy, :create, :update],
         :redirect_to => {:action => :list}

  def add_signup_topics_staggered
    load_add_signup_topics(params[:id])

    @review_rounds = Assignment.find(params[:id]).get_review_rounds
    @topics = SignUpTopic.find_all_by_assignment_id(params[:id])

    #Use this until you figure out how to initialize this array
    @duedates = SignUpTopic.find_by_sql("SELECT s.id as topic_id FROM sign_up_topics s WHERE s.assignment_id = " + params[:id].to_s)

    if !@topics.nil?
      i=0
      @topics.each { |topic|

        @duedates[i]['t_id'] = topic.id
        @duedates[i]['topic_identifier'] = topic.topic_identifier
        @duedates[i]['topic_name'] = topic.topic_name

        for j in 1..@review_rounds
          if j == 1
            duedate_subm = TopicDeadline.find_by_topic_id_and_deadline_type_id(topic.id, DeadlineType.find_by_name('submission').id)
            duedate_rev = TopicDeadline.find_by_topic_id_and_deadline_type_id(topic.id, DeadlineType.find_by_name('review').id)
          else
            duedate_subm = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(topic.id, DeadlineType.find_by_name('resubmission').id, j)
            duedate_rev = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(topic.id, DeadlineType.find_by_name('rereview').id, j)
          end
          if !duedate_subm.nil? && !duedate_rev.nil?
            @duedates[i]['submission_'+ j.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
            @duedates[i]['review_'+ j.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
          else
            #the topic is new. so copy deadlines from assignment
            set_of_due_dates = DueDate.find_all_by_assignment_id(params[:id])
            set_of_due_dates.each { |due_date|
              create_topic_deadline(due_date, 0, topic.id)
            }
            # code execution would have hit the else part during review_round one. So we'll do only round one
            duedate_subm = TopicDeadline.find_by_topic_id_and_deadline_type_id(topic.id, DeadlineType.find_by_name('submission').id)
            duedate_rev = TopicDeadline.find_by_topic_id_and_deadline_type_id(topic.id, DeadlineType.find_by_name('review').id)
            @duedates[i]['submission_'+ j.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
            @duedates[i]['review_'+ j.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
          end

        end
        duedate_subm = TopicDeadline.find_by_topic_id_and_deadline_type_id(topic.id, DeadlineType.find_by_name('metareview').id)
        if !duedate_subm.nil?
          @duedates[i]['submission_'+ (@review_rounds+1).to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
        else
          @duedates[i]['submission_'+ (@review_rounds+1).to_s] = nil
        end
        i = i + 1
      }
    end
  end

  def add_signup_topics
    load_add_signup_topics(params[:id])
  end

  def view_publishing_rights
    load_add_signup_topics(params[:id])
  end

  def load_add_signup_topics(assignment_id)
    @id = assignment_id
    @sign_up_topics = SignUpTopic.find(:all, :conditions => ['assignment_id = ?', assignment_id])
    @slots_filled = SignUpTopic.find_slots_filled(assignment_id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(assignment_id)

    @assignment = Assignment.find(assignment_id)
    if !@assignment.team_assignment
      @participants = SignedUpUser.find_participants(assignment_id)
    else
      @participants = SignedUpUser.find_team_participants(assignment_id)
    end
  end

  def new
    @id = params[:id]
    @sign_up_topic = SignUpTopic.new
  end

  #This method is used to create signup topics
  #In this code params[:id] is the assignment id and not topic id. The intuition is 
  #that assignment id will virtually be the signup sheet id as well as we have assumed 
  #that every assignment will have only one signup sheet
  def create
    topic = SignUpTopic.find_by_topic_name_and_assignment_id(params[:topic][:topic_name], params[:id])

    #if the topic already exists then update
    if topic != nil
      topic.topic_identifier = params[:topic][:topic_identifier]

      #While saving the max choosers you should be careful; if there are users who have signed up for this particular
      #topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
      #there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
      #it.
      if SignedUpUser.find_by_topic_id(topic.id).nil? || topic.max_choosers == params[:topic][:max_choosers]
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
      @sign_up_topic = SignUpTopic.new
      @sign_up_topic.topic_identifier = params[:topic][:topic_identifier]
      @sign_up_topic.topic_name = params[:topic][:topic_name]
      @sign_up_topic.max_choosers = params[:topic][:max_choosers]
      @sign_up_topic.category = params[:topic][:category]
      @sign_up_topic.assignment_id = params[:id]

      @assignment = Assignment.find(params[:id])

      if @assignment.staggered_deadline?
        topic_set = Array.new
        topic = @sign_up_topic.id

      end

      if @sign_up_topic.save
        #NotificationLimit.create(:topic_id => @sign_up_topic.id)
        flash[:notice] = 'Topic was successfully created.'
        redirect_to_sign_up(params[:id])
      else
        render :action => 'new', :id => params[:id]
      end
    end
  end

  def redirect_to_sign_up(assignment_id)
    assignment = Assignment.find(assignment_id)
    if assignment.staggered_deadline == true
      redirect_to :action => 'add_signup_topics_staggered', :id => assignment_id
    else
      redirect_to :action => 'add_signup_topics', :id => assignment_id
    end
  end

  #This method is used to delete signup topics
  def delete
    @topic = SignUpTopic.find(params[:id])

    if !@topic.nil?
      @topic.destroy
    else
      flash[:error] = "Topic could not be deleted"
    end

    #if this assignment has staggered deadlines then destroy the dependencies as well    
    if Assignment.find(params[:assignment_id])['staggered_deadline'] == true
      dependencies = TopicDependency.find_all_by_topic_id(params[:id])
      if !dependencies.nil?
        dependencies.each { |dependency| dependency.destroy }
      end
    end
    redirect_to_sign_up(params[:assignment_id])
  end

  def edit
    @topic = SignUpTopic.find(params[:id])
    @assignment_id = params[:assignment_id]
  end

  def update
    topic = SignUpTopic.find(params[:id])

    if !topic.nil?
      topic.topic_identifier = params[:topic][:topic_identifier]

      #While saving the max choosers you should be careful; if there are users who have signed up for this particular
      #topic and are on waitlist, then they have to be converted to confirmed topic based on the availability. But if
      #there are choosers already and if there is an attempt to decrease the max choosers, as of now I am not allowing
      #it.
      if SignedUpUser.find_by_topic_id(topic.id).nil? || topic.max_choosers == params[:topic][:max_choosers]
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
      topic.topic_name = params[:topic][:topic_name]
      topic.save
    else
      flash[:error] = "Topic could not be updated"
    end
    redirect_to_sign_up(params[:assignment_id])
  end

  def signup_topics
    @assignment_id = params[:id]
    @sign_up_topics = SignUpTopic.find(:all, :conditions => ['assignment_id = ?', params[:id]])
    @slots_filled = SignUpTopic.find_slots_filled(params[:id])
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(params[:id])
    @show_actions = true

    #find whether assignment is team assignment
    assignment = Assignment.find(params[:id])


    if !assignment.staggered_deadline? and assignment.due_dates.find_by_deadline_type_id(1).due_at < Time.now
      @show_actions = false
    end

    #Find whether the user has signed up for any topics; if so the user won't be able to
    #sign up again unless the former was a waitlisted topic
    #if team assignment, then team id needs to be passed as parameter else the user's id
    if assignment.team_assignment == true
      users_team = SignedUpUser.find_team_participants(params[:id], (session[:user].id))

      if users_team.size == 0
        @selected_topics = nil
      else
        #TODO: fix this; cant use 0
        @selected_topics = otherConfirmedTopicforUser(params[:id], users_team[0].t_id)
      end
    else
      @selected_topics = otherConfirmedTopicforUser(params[:id], session[:user].id)
    end
  end

  #this function is used to delete a previous signup
  def delete_signup
    delete_signup_for_topic(params[:assignment_id], params[:id])
    redirect_to :action => 'signup_topics', :id => params[:assignment_id]
  end

  def delete_signup_for_topic(assignment_id, topic_id)
    #find whether assignment is team assignment
    assignment = Assignment.find(assignment_id)

    #making sure that the drop date deadline hasn't passed
    dropDate = DueDate.find(:first, :conditions => {:assignment_id => assignment.id, :deadline_type_id => '6'})
    if (!dropDate.nil? && dropDate.due_at < Time.now)
      flash[:error] = "You cannot drop this topic because the drop deadline has passed."
    else
      #if team assignment find the creator id from teamusers table and teams
      if assignment.team_assignment == true
        #users_team will contain the team id of the team to which the user belongs
        users_team = SignedUpUser.find_team_participants(assignment_id, (session[:user].id))
        signup_record = SignedUpUser.find_by_topic_id_and_creator_id(topic_id, users_team[0].t_id)
      else
        signup_record = SignedUpUser.find_by_topic_id_and_creator_id(topic_id, session[:user].id)
      end

      #if a confirmed slot is deleted then push the first waiting list member to confirmed slot if someone is on the waitlist
      if signup_record.is_waitlisted == false
        #find the first wait listed user if exists
        first_waitlisted_user = SignedUpUser.find_by_topic_id_and_is_waitlisted(topic_id, true)

        if !first_waitlisted_user.nil?
          # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
          ### Bad policy!  Should be changed! (once users are allowed to specify waitlist priorities) -efg
          first_waitlisted_user.is_waitlisted = false
          first_waitlisted_user.save

          #update the participants details
          if assignment.team_assignment?
            user_id = TeamsParticipant.find(:first, :conditions => {:team_id => first_waitlisted_user.creator_id}).user_id
            participant = Participant.find_by_user_id_and_parent_id(user_id, assignment.id)
          else
            participant = Participant.find_by_user_id_and_parent_id(first_waitlisted_user.creator_id, assignment.id)
          end
          participant.update_topic_id(topic_id)

          SignUpTopic.cancel_all_waitlists(first_waitlisted_user.creator_id, assignment_id)
        end
      end

      if !signup_record.nil?
        participant = Participant.find_by_user_id_and_parent_id(session[:user].id, assignment_id)
        #update participant's topic id to nil
        participant.update_topic_id(nil)
        signup_record.destroy
      end
    end #end condition for 'drop deadline' check
  end

  def signup
    #find the assignment to which user is signing up
    assignment = Assignment.find(params[:assignment_id])

    #check whether team assignment. This is to decide whether a team_id or user_id should be the creator_id
    if assignment.team_assignment == true

      #check whether the user already has a team for this assignment
      users_team = SignedUpUser.find_team_participants(params[:assignment_id], (session[:user].id))

      if users_team.size == 0
        #if team is not yet created, create new team.
        team = create_team(params[:assignment_id])
        user = User.find(session[:user].id)
        teamuser = create_team_users(user, team.id)
        confirmationStatus = confirmTopic(team.id, params[:id], params[:assignment_id])
      else
        confirmationStatus = confirmTopic(users_team[0].t_id, params[:id], params[:assignment_id])
      end
    else
      confirmationStatus = confirmTopic(session[:user].id, params[:id], params[:assignment_id])
    end
    redirect_to :action => 'signup_topics', :id => params[:assignment_id]
  end

  # When using this method when creating fields, update race conditions by using db transactions
  def slotAvailable?(topic_id)
    SignUpTopic.slotAvailable?(topic_id)
  end

  def otherConfirmedTopicforUser(assignment_id, creator_id)
    user_signup = SignedUpUser.find_user_signup_topics(assignment_id, creator_id)
    user_signup
  end

  def confirmTopic(creator_id, topic_id, assignment_id)
    #check whether user has signed up already
    user_signup = otherConfirmedTopicforUser(assignment_id, creator_id)

    sign_up = SignedUpUser.new
    sign_up.topic_id = params[:id]
    sign_up.creator_id = creator_id

    result = false
    if user_signup.size == 0

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        #check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        if slotAvailable?(topic_id)
          sign_up.is_waitlisted = false

          #Update topic_id in participant table with the topic_id
          participant = Participant.find_by_user_id_and_parent_id(session[:user].id, assignment_id)

          participant.update_topic_id(topic_id)
        else
          sign_up.is_waitlisted = true
        end
        if sign_up.save
          result = true
        end
      end
    else
      #If all the topics choosen by the user are waitlisted,
      for user_signup_topic in user_signup
        if user_signup_topic.is_waitlisted == false
          flash[:error] = "You have already signed up for a topic."
          return false
        end
      end

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        #check whether user is clicking on a topic which is not going to place him in the waitlist
        if !slotAvailable?(topic_id)
          sign_up.is_waitlisted = true
          if sign_up.save
            result = true
          end
        else
          #if slot exist, then confirm the topic for the user and delete all the waitlist for this user        
          SignUpTopic.cancel_all_waitlists(creator_id, assignment_id)
          sign_up.is_waitlisted = false
          sign_up.save

          participant = Participant.find_by_user_id_and_parent_id(session[:user].id, assignment_id)
          participant.update_topic_id(topic_id)
          result = true
        end
      end
    end

    result
  end

  def create_team(assignment_id)
    assignment = Assignment.find(assignment_id)
    #check_for_existing_team_name(parent,generate_team_name(parent.name))
    teamname = generate_team_name(assignment.name)
    team = AssignmentTeam.create(:name => teamname, :parent_id => assignment.id)
    TeamNode.create(:parent_id => assignment.id, :node_object_id => team.id)
    team
  end

  def generate_team_name(teamnameprefix)
    counter = 1
    while (true)
      teamname = teamnameprefix + "_Team#{counter}"
      if (!Team.find_by_name(teamname))
        return teamname
      end
      counter=counter+1
    end
  end

  def create_team_users(user, team_id)
    #user = User.find_by_name(params[:user][:name].strip)
    if !user
      urlCreate = url_for :controller => 'users', :action => 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
    end
    team = Team.find(team_id)
    team.add_member(user)
  end

  def has_user(user, team_id)
    if TeamsParticipant.find_by_team_id_and_user_id(team_id, user.id)
      return true
    else
      return false
    end
  end

  def save_topic_dependencies
    # Prevent injection attacks - we're using this in a system() call later
    params[:assignment_id] = params[:assignment_id].to_i.to_s

    topics = SignUpTopic.find_all_by_assignment_id(params[:assignment_id])
    topics = topics.collect { |topic|
      #if there is no dependency for a topic then there wont be a post for that tag.
      #if this happens store the dependency as "0"
      if !params['topic_dependencies_' + topic.id.to_s].nil?
        [topic.id, params['topic_dependencies_' + topic.id.to_s][:dependent_on]]
      else
        [topic.id, ["0"]]
      end
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

    graph_output_path = 'public/images/staggered_deadline_assignment_graph'
    FileUtils::mkdir_p graph_output_path
    dg.write_to_graphic_file('jpg', "#{graph_output_path}/graph_#{params[:assignment_id]}")

    redirect_to_sign_up(params[:assignment_id])
  end

  def stringtodate(date)
    DateTime.parse(date)
  end


  #If the instructor needs to explicitly change the start/due dates of the topics
  def save_topic_deadlines

    due_dates = params[:due_date]

    review_rounds = Assignment.find(params[:assignment_id]).get_review_rounds
    due_dates.each { |due_date|
      for i in 1..review_rounds
        if i == 1
          topic_deadline_type_subm = DeadlineType.find_by_name('submission').id
          topic_deadline_type_rev = DeadlineType.find_by_name('review').id
        else
          topic_deadline_type_subm = DeadlineType.find_by_name('resubmission').id
          topic_deadline_type_rev = DeadlineType.find_by_name('rereview').id
        end

        topic_deadline_subm = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(due_date['t_id'].to_i, topic_deadline_type_subm, i)
        topic_deadline_subm.update_attributes({'due_at' => due_date['submission_' + i.to_s]})
        flash[:error] = "Please enter a valid " + (i > 1 ? "Resubmission deadline " + (i-1).to_s : "Submission deadline") if topic_deadline_subm.errors.length > 0

        topic_deadline_rev = TopicDeadline.find_by_topic_id_and_deadline_type_id_and_round(due_date['t_id'].to_i, topic_deadline_type_rev, i)
        topic_deadline_rev.update_attributes({'due_at' => due_date['review_' + i.to_s]})
        flash[:error] = "Please enter a valid Review deadline " + (i > 1 ? (i-1).to_s : "") if topic_deadline_rev.errors.length > 0
      end

      topic_deadline_subm = TopicDeadline.find_by_topic_id_and_deadline_type_id(due_date['t_id'], DeadlineType.find_by_name('metareview').id)
      topic_deadline_subm.update_attributes({'due_at' => due_date['submission_' + (review_rounds+1).to_s]})
      flash[:error] = "Please enter a valid Meta review deadline" if topic_deadline_subm.errors.length > 0
    }

    redirect_to_sign_up(params[:assignment_id])
  end

  def build_dependency_graph(topics, node)
    dg = RGL::DirectedAdjacencyGraph.new

    #create a graph of the assignment with appropriate dependency
    topics.collect { |topic|
      topic[1].each { |dependent_node|
        edge = Array.new
        #if a topic is not dependent on any other topic
        dependent_node = dependent_node.to_i
        if dependent_node == 0
          edge.push("fake")
        else
          #if we want the topic names to be displayed in the graph replace node to topic_name
          edge.push(SignUpTopic.find(dependent_node)[node])
        end
        edge.push(SignUpTopic.find(topic[0])[node])
        dg.add_edges(edge)
      }
    }
    #remove the fake vertex
    dg.remove_vertex("fake")
    dg
  end

  def create_common_start_time_topics(dg)
    dg_reverse = dg.clone.reverse()
    set_of_topics = Array.new

    while !dg_reverse.empty?
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

  def create_topic_deadline(due_date, offset, topic_id)
    topic_deadline = TopicDeadline.new
    topic_deadline.topic_id = topic_id
    topic_deadline.due_at = DateTime.parse(due_date.due_at.to_s) + offset.to_i
    topic_deadline.deadline_type_id = due_date.deadline_type_id
    topic_deadline.late_policy_id = due_date.late_policy_id
    topic_deadline.submission_allowed_id = due_date.submission_allowed_id
    topic_deadline.review_allowed_id = due_date.review_allowed_id
    topic_deadline.resubmission_allowed_id = due_date.resubmission_allowed_id
    topic_deadline.rereview_allowed_id = due_date.rereview_allowed_id
    topic_deadline.review_of_review_allowed_id = due_date.review_of_review_allowed_id
    topic_deadline.round = due_date.round
    topic_deadline.save
  end

  def set_start_due_date(assignment_id, set_of_topics)

    #Remember, in create_common_start_time_topics function we reversed the graph so reverse it back
    set_of_topics = set_of_topics.reverse

    set_of_topics_due_dates = Array.new
    i=0
    days_between_submissions = Assignment.find(assignment_id)['days_between_submissions'].to_i
    set_of_topics.each { |set_of_topic|
      set_of_due_dates = nil
      if i==0
        #take the first set from the table which user stores
        set_of_due_dates = DueDate.find_all_by_assignment_id(assignment_id)
        offset = 0
      else
        set_of_due_dates = TopicDeadline.find_all_by_topic_id(set_of_topics[i-1][0])

        set_of_due_dates.sort! { |a, b| a.due_at <=> b.due_at }

        offset = days_between_submissions
      end

      set_of_topic.each { |topic_id|
        #if the due dates have already been created and the save dependency is being clicked,
        #then delete existing n create again
        prev_saved_due_dates = TopicDeadline.find_all_by_topic_id(topic_id)

        #Only if there is a dependency for the topic
        if !prev_saved_due_dates.nil?
          num_due_dates = prev_saved_due_dates.length
          #for each due date in the current topic he want to compare it to the previous due date
          for x in 0..num_due_dates - 1
            #we don't want the old date to move earlier in time so we save it as the new due date and destroy the old one  
            if DateTime.parse(set_of_due_dates[x].due_at.to_s) + offset.to_i < DateTime.parse(prev_saved_due_dates[x].due_at.to_s)
              set_of_due_dates[x] = prev_saved_due_dates[x]
              offset = 0
            end
            prev_saved_due_dates[x].destroy
          end
        end

        set_of_due_dates.each { |due_date|
          create_topic_deadline(due_date, offset, topic_id)
        }
      }
      i = i+1
    }

  end

  #gets team_details to show it on team_details view for a given assignment
  def team_details
    if !(assignment = Assignment.find(params[:assignment_id])).nil? and !(topic = SignUpTopic.find(params[:id])).nil?
      @results =get_team_details(assignment.id, topic.id)
      @results.each do |result|
        result.attributes().each do |attr|
          if attr[0].equal? "name"
            @current_team_name = attr[1]
          end
        end
      end
      @results.each { |result|
        @team_members = ""
        TeamsParticipant.find_all_by_team_id(result[:team_id]).each { |teamuser|
          puts 'Userblaahsdb asd' +User.find(teamuser.user_id).to_json
          @team_members+=User.find(teamuser.user_id).name+" "
        }
      }
      #@team_members = find_team_members(topic)  
    end
  end

  #searches and returns team members for a given team_id
  def find_team_members(team_id)
    TeamsParticipant.find_all_by_team_id(team_id).each { |teamuser|
      team_members+=User.find(teamuser.user_id).handle+" "
    }
  end

  #get the team details to display them in team_details view when assignment-participant
  #clicks for seeing the advertisement related to
  def get_team_details(assignment_id, topic_id)
    query = "select t.name, t.comments_for_advertisement, p.handle,t.id as team_id, p.id as participant_id, p.topic_id as topic_id, p.parent_id as assignment_id"
    query = query + " from teams t, teams_participants tu, participants p"
    query = query + " where"
    query = query + " p.parent_id = '#{assignment_id}' and"
    query = query + " p.topic_id = '#{topic_id}'  and"
    query = query + " t.parent_id = p.parent_id and"
    query = query + " tu.user_id = p.user_id and"
    query = query + " t.id = tu.team_id"
    query = query + " group by t.name;"
    SignUpTopic.find_by_sql(query)
  end
end
