class SignUpSheetController < ApplicationController
  #require 'rgl/adjacency'
  #require 'rgl/dot'
  #require 'graph/graphviz_dot'
  #require 'rgl/topsort'


  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def add_signup_topics_staggered
    load_add_signup_topics(params[:id])

    @duedates = SignUpTopic.find_by_sql("SELECT s.id as topic_id, s.due_date as due_date,s.start_date as start_date FROM sign_up_topics s WHERE s.assignment_id = " + params[:id] + "")
    @submission_due_dates = Array.new
    @review_due_dates = Array.new
    @resubmission_due_date = Array.new

    i=0
    if !@duedates.nil?
      @duedates.each {|duedate|
        if !duedate['start_date'].nil?
          a_startdate = stringtodate(duedate['start_date'].to_s)
          a_duedate = stringtodate(duedate['due_date'].to_s)
          days = a_duedate - a_startdate

          submission_time = (0.6)*days
          review_time = (0.2)*days

          @submission_due_dates.insert(i, a_startdate+submission_time)
          @review_due_dates.insert(i, a_startdate+(submission_time+review_time))
          @resubmission_due_date.insert(i, a_startdate+(submission_time+review_time+review_time))
          i = i+1
        end
      }
    end
  end

  def add_signup_topics
    load_add_signup_topics(params[:id])
  end

  def load_add_signup_topics(assignment_id)
    @id = assignment_id
    @sign_up_topics = SignUpTopic.find(:all, :conditions => ['assignment_id = ?', assignment_id])
    @slots_filled = SignUpTopic.find_slots_filled(assignment_id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(assignment_id)

    assignment = Assignment.find(assignment_id)
    if !assignment.team_assignment
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
        dependencies.each {|dependency| dependency.destroy}
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
    @slots_filled =  SignUpTopic.find_slots_filled(params[:id])
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(params[:id])

    #find whether assignment is team assignment
    this_assignment = Assignment.find(params[:id])

    #Find whether the user has signed up for any topics, if so the user won't be able to
    #signup again unless the former was a waitlisted topic
    #if team assignment, then team id needs to be passed as parameter else the user's id
    if this_assignment.team_assignment == true
      users_team = SignedUpUser.find_team_users(params[:id],(session[:user].id))

      if users_team.size == 0
        @selected_topics = nil
      else
        @selected_topics = otherConfirmedTopicforUser(params[:id], users_team[0].t_id)
      end
    else
      @selected_topics = otherConfirmedTopicforUser(params[:id], session[:user].id)
    end
  end

  #this function is used to delete a previous signup
  def delete_signup
    delete_signup_for_topic(params[:assignment_id],params[:id])    
    redirect_to :action => 'signup_topics', :id => params[:assignment_id]
  end

  def delete_signup_for_topic(assignment_id,topic_id)
    #find whether assignment is team assignment
    this_assignment = Assignment.find(assignment_id)

    #if team assignment find the creator id from teamusers table and teams
    if this_assignment.team_assignment == true
      #users_team will contain the team id of the team to which the user belongs
      users_team = SignedUpUser.find_team_users(assignment_id,(session[:user].id))
      signup_record = SignedUpUser.find_by_topic_id_and_creator_id(topic_id, users_team[0].t_id)
    else
      signup_record = SignedUpUser.find_by_topic_id_and_creator_id(topic_id, session[:user].id)
    end

    #if a confirmed slot is deleted then push the first waiting list member to confirmed slot if someone is on the waitlist
    if signup_record.is_waitlisted == false
      #find the first wait listed user if exists
      first_waitlisted_user = SignedUpUser.find_by_topic_id_and_is_waitlisted(topic_id, true)

      if !first_waitlisted_user.nil?
        #As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
        first_waitlisted_user.is_waitlisted = false
        first_waitlisted_user.save
        SignUpTopic.cancel_all_waitlists(first_waitlisted_user.creator_id,assignment_id)
      end
    end

    if !signup_record.nil?
      signup_record.destroy
    end
  end

  def signup
    #find the assignment to which user is signing up
    assignment = Assignment.find(params[:assignment_id])

    #check whether team assignment. This is to decide whether a team_id or user_id should be the creator_id
    if assignment.team_assignment == true

      #check whether the user already has a team for this assignment
      users_team = SignedUpUser.find_team_users(params[:assignment_id],(session[:user].id))

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

  def slotExist?(topic_id)
    SignUpTopic.slotExist?(topic_id)
  end

  def otherConfirmedTopicforUser(assignment_id, creator_id)
    user_signup = SignedUpUser.find_user_signup_topics(assignment_id,creator_id)
    user_signup
  end

  def confirmTopic(creator_id, topic_id, assignment_id)
    #check whether user has signed up already
    user_signup = otherConfirmedTopicforUser(assignment_id, creator_id)

    sign_up = SignedUpUser.new
    sign_up.topic_id = params[:id]
    sign_up.creator_id = creator_id
    if user_signup.size == 0
      #check whether slots exist (params[:id] = topic_id) or has the user selected another topic
      if slotExist?(topic_id)
        sign_up.is_waitlisted = false
      else
        sign_up.is_waitlisted = true
      end
      if sign_up.save
        return true
        flash[:error] = "Your topic has been confirmed."
      else
        return false
      end
    else
      #If all the topics choosen by the user are waitlisted,
      for user_signup_topic in user_signup
        if user_signup_topic.is_waitlisted == false
          flash[:error] = "You have already signed up for a topic."
          return false
        end
      end
      #check whether user is clicking on a topic which is not going to place him in the waitlist
      if !slotExist?(topic_id)
        sign_up.is_waitlisted = true
        if sign_up.save
          return true
        else
          return false
        end
      else
        #if slot exist, then confirm the topic for the user and delete all the waitlist for this user        
        SignUpTopic.cancel_all_waitlists(creator_id, assignment_id)
        sign_up.is_waitlisted = false
        sign_up.save
        return true
      end
    end
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
    if TeamsUser.find_by_team_id_and_user_id(team_id, user.id)
      return true
    else
      return false
    end
  end

  def save_topic_dependencies
    topics = SignUpTopic.find_all_by_assignment_id(params[:assignment_id])
    topics = topics.collect {|topic|
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
    dg = build_dependency_graph(topics,node)
    #Clone the graph    
    dg_clone = RGL::DirectedAdjacencyGraph.new
    dg_clone = dg.clone

    if dg.acyclic?
      #This method produces sets of vertexes which should have common start time/deadlines
      puts "****************"
      puts "going inside create_common_start_time_topics"
      set_of_topics = create_common_start_time_topics(dg_clone)
      puts "****************"
      puts "going inside set_start_due_date"
      set_start_due_date(params[:assignment_id],set_of_topics)
      puts "****************"
      puts "sorting"            
      @top_sort = dg.topsort_iterator.to_a
    else
      flash[:error] = "There may be one or more cycles in the dependencies. Please correct them"
    end


    node = 'topic_name'
    dg = build_dependency_graph(topics,node)

    dg.write_to_graphic_file('jpg',"graph_" + params[:assignment_id])

    #http://www.graphviz.org/pdf/dotguide.pdf
    begin
      cmd = "C:\\Graphviz2.26\\bin\\dot.exe -Tjpg C:\\InstantRails\\rails_apps\\pg\\graph_" + params[:assignment_id] + ".dot -o C:\\InstantRails\\rails_apps\\pg\\public\\images\\staggered_deadline_assignment_graph\\graph_"+ params[:assignment_id] +".jpg"
      system(cmd)
      cmd
    end

    redirect_to_sign_up(params[:assignment_id])
  end

  def stringtodate(date)
    #assignment_endDate returns a value like Tue Dec 29 01:57:23 -0500 2009. So I had to split it up and get MMDDYYYY
    date_array = date.split(" ")

    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    month = months.index(date_array[1])+1

    #date_array[5] => year, date_array[2] => date
    #Format :: DateTime.new(year,month,date)
    formatted_date = DateTime.new(date_array[5].to_i,month,date_array[2].to_i)
    formatted_date
  end


  #If the instructor needs to explicitly change the start/due dates of the topics
  def save_topic_deadlines

    due_dates = params[:due_date]

    due_dates.each {|due_date|
      dependency_record = TopicDependency.find_by_topic_id(due_date['topic_id'])

      if !dependency_record.nil?
        dependency_record.start_date = due_date['start_date']
        dependency_record.due_date = due_date['due_date']
        dependency_record.save
      end
    }

    redirect_to_sign_up(params[:assignment_id])    
  end

  def build_dependency_graph(topics,node)
    dg = RGL::DirectedAdjacencyGraph.new

    #create a graph of the assignment with appropriate dependency
    topics.collect {|topic|
      topic[1].each {|dependent_node|
        edge  = Array.new
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

  #TODO: Improve this function to find sets by determining which vertex has indegree 0
  def create_common_start_time_topics(dg_clone)
    set_of_topics = Array.new
    i=0
    puts "graph : "
    puts dg_clone.inspect
    while !dg_clone.empty?
      array_of_vertices = Array.new
      array_of_vertices = dg_clone.vertices
      puts 'array_of_vertices : ' + array_of_vertices.inspect

      #find all the adjacent vertices of every vertex
      dg_clone.each_vertex {|vertex|
        puts 'going for the vertex :' + vertex.inspect
        adj_ver = dg_clone.adjacent_vertices(vertex)
        puts ' adj_ver :' + adj_ver.inspect
        adj_ver.each {|adj_ver_of_vertex|
          puts "deleting vertex : " + adj_ver_of_vertex.inspect
          array_of_vertices.delete(adj_ver_of_vertex.to_s)}
      }

      array_of_vertices.each {|vertex|
        puts "removing vertex from dg_clone :" + vertex.inspect        
        dg_clone.remove_vertex(vertex)
        puts dg_clone.inspect
      }
      set_of_topics.insert(i, array_of_vertices)
      i = i+1
    end
    set_of_topics
  end

  def set_start_due_date(assignment_id,set_of_topics)
      begin
        startDate = Assignment.find(assignment_id)['start_date']
      rescue
        startDate = Time.new       
      end

      endDate = DueDate.find_by_assignment_id_and_deadline_type_id(assignment_id,5)['due_at'].to_s

      #convert to desired format for "date" functions
      assignment_startdate = stringtodate(startDate.to_s)
      assignment_enddate = stringtodate(endDate.to_s)

      num_of_days = assignment_enddate - assignment_startdate

      #number of days to be allocated for each topic with common start/end date
      set_days =  num_of_days/set_of_topics.size

      set_due_date = assignment_startdate
      set_of_topics.each { |set_of_topic|
        set_due_date = set_due_date + set_days
        set_of_topic.each { |topic|
          #topic_record = TopicDependency.find_by_topic_id(SignUpTopic.find_by_topic_identifier(topic)['id'])
          topic_record = SignUpTopic.find(topic)
          if !topic_record.nil?
            topic_record.due_date = set_due_date
            topic_record.start_date = set_due_date - set_days
            topic_record.save
          end          
        }
      }
  end


end




