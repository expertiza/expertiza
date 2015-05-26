class SignUpSheet < ActiveRecord::Base
  def signup_team ( assignment_id, user_id, topic_id )
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.size == 0
      #if team is not yet created, create new team.
      team = AssignmentTeam.create_team_and_node(assignment_id)
      user = User.find(user_id)

      teamuser = create_team_users(user, team.id)
      confirmationStatus = confirmTopic(team.id, topic_id, assignment_id)
    else
      confirmationStatus = confirmTopic(users_team[0].t_id, topic_id, assignment_id)
    end
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
