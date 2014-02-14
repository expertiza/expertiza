class SignUpSheet < ActiveRecord::Base
  def signup_team ( assignment_id, user_id, topic_id )
    users_team = SignedUpUser.find_team_users(assignment_id, user_id)
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
end
