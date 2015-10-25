class SignUpSheet < ActiveRecord::Base
  #Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id=nil)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.size == 0
      #if team is not yet created, create new team.
      #create Team and TeamNode
      team = AssignmentTeam.create_team_and_node(assignment_id)
      user = User.find(user_id)
      #create TeamsUser and TeamUserNode
      teamuser = ApplicationController.helpers.create_team_users(user, team.id)
      #create SignedUpTeam
      confirmationStatus = SignUpSheet.confirmTopic(user_id, team.id, topic_id, assignment_id) if topic_id
    else
      confirmationStatus = SignUpSheet.confirmTopic(user_id, users_team[0].t_id, topic_id, assignment_id) if topic_id
    end
  end

  def self.confirmTopic(user_id, team_id, topic_id, assignment_id)
    #check whether user has signed up already
    user_signup = SignUpSheet.otherConfirmedTopicforUser(assignment_id, team_id)

    sign_up = SignedUpTeam.new
    sign_up.topic_id = topic_id
    sign_up.team_id = team_id
    result = false
    if user_signup.size == 0

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        #check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        if slotAvailable?(topic_id)
          sign_up.is_waitlisted = false
          #Create new record in signed_up_teams table
          team_id = TeamsUser.team_id(assignment_id, user_id)
          topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
          SignedUpTeam.create(topic_id: topic_id, team_id: team_id, is_waitlisted: 0, preference_priority_number: nil)
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
          Waitlist.cancel_all_waitlists(team_id, assignment_id)
          sign_up.is_waitlisted = false
          sign_up.save
          #Update topic_id in signed_up_teams table with the topic_id
          team_id = SignedUpTeam.find_team_users(assignment_id, user_id)
          signUp = SignedUpTeam.where(topic_id: topic_id).first
          signUp.update_attribute('topic_id', topic_id)
          result = true
        end
      end
    end

    result
  end

  def self.otherConfirmedTopicforUser(assignment_id, team_id)
    user_signup = SignedUpTeam.find_user_signup_topics(assignment_id, team_id)
    user_signup
  end

  # When using this method when creating fields, update race conditions by using db transactions
  def self.slotAvailable?(topic_id)
    SignUpTopic.slotAvailable?(topic_id)
  end

  def self.create_dependency_graph(topics,node)
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

  def self.add_signup_topic ( assignment_id )
        @review_rounds = Assignment.find(assignment_id).get_review_rounds
        @topics = SignUpTopic.where(assignment_id: assignment_id)

        #Use this until you figure out how to initialize this array
        #@duedates = SignUpTopic.find_by_sql("SELECT s.id as topic_id FROM sign_up_topics s WHERE s.assignment_id = " + assignment_id.to_s)
        @duedates = {}
        return @duedates if @topics.nil?
          i=0
          @topics.each { |topic|
            @duedates[i] = {}
            @duedates[i]['id'] = topic.id
            @duedates[i]['topic_identifier'] = topic.topic_identifier
            @duedates[i]['topic_name'] = topic.topic_name

            for j in 1..@review_rounds
              duedate_subm = TopicDeadline.where(topic_id: topic.id, deadline_type_id:  DeadlineType.find_by_name('submission').id, round: j).first
              duedate_rev = TopicDeadline.where(topic_id: topic.id, deadline_type_id:  DeadlineType.find_by_name('review').id, round: j).first
              if !duedate_subm.nil? && !duedate_rev.nil?
                @duedates[i]['submission_'+ j.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
                @duedates[i]['review_'+ j.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
              else
                #the topic is new. so copy deadlines from assignment
                set_of_due_dates = DueDate.where(assignment_id: assignment_id)
                set_of_due_dates.each { |due_date|
                  DueDate.assign_topic_deadline(due_date, 0, topic.id)
                }
                duedate_subm = TopicDeadline.where(topic_id: topic.id, deadline_type_id:  DeadlineType.find_by_name('submission').id, round: j).first
                duedate_rev = TopicDeadline.where(topic_id: topic.id, deadline_type_id:  DeadlineType.find_by_name('review').id, round: j).first
                @duedates[i]['submission_'+ j.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
                @duedates[i]['review_'+ j.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
              end
            end
            duedate_subm = TopicDeadline.where(topic_id: topic.id, deadline_type_id:  DeadlineType.find_by_name('metareview').id).first
            @duedates[i]['submission_'+ (@review_rounds+1).to_s] = !(duedate_subm.nil?)?(DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")):nil
            i = i + 1
          }
          return @duedates
      end
end
