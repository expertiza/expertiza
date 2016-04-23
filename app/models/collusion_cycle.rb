#new class created to handle code related to cycles between reviews
#This code was previously in AssignmentParticipant and is not being used anywhere yet
class CollusionCycle < ActiveRecord::Base
  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given by to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.


    #Begin Changes ==== Create a method to make a graph
  def self.create_graph_response_map(assignment)
    graph = Hash.new

    @response_maps = ResponseMap.select("*").where(["type=? and reviewed_object_id=?", "ReviewResponseMap", assignment])

    for response_map in @response_maps
      @response = Response.find_by_map_id(response_map.id)
      if ! @response.nil?
        reviewer_user_id = get_user_from_reviewer(response_map.reviewer)
        reviewee_user_id = get_user_from_reviewee(response_map.reviewee)
        if graph.key?(reviewer_user_id)
          graph.values_at(reviewer_user_id).append(reviewee_user_id)
        else
          graph[reviewer_user_id] = reviewee_user_id
        end
      end
    end

    graph
  end

  # Get user_id from reviewer, which actually is the participant ID
  def self.get_user_from_reviewer(reviewer)
    @user = AssignmentParticipant.find(reviewer).user
    @user.id
  end

  # Get user_id from reviewee, which actually is the team, so get all the members of the team
  def self.get_user_from_reviewee(reviewee)
    @assinment_team = AssignmentTeam.find(reviewee)
    reviewee_user_ids = []
    participants = @assinment_team.participants

    for participant in participants
      @participant = Participant.find(participant)
      if !@participant.nil?
        reviewee_user_ids.append(@participant.user_id)
      end
    end

    reviewee_user_ids
  end
  #End Changes ==== Create a method to make a graph


  # Begin Changes ==== Create a method to do DFS on the graph and return nodes for which there is a cycle and parent array
  def self.cycle_detection(graph)
    white_set = Set.new
    gray_set = Set.new
    black_set = Set.new
    parent = Hash.new
    cycle = Hash.new
    return_matrix = []

    # fill white set with all the vertices assuming each person did atleast 1 review
    graph.each do |current,neighbours|
      white_set.add(current)
      parent[current] = -1
    end

    graph.each do |current, neighbours|
      dfs_within_graph(current, white_set, gray_set, black_set, graph,parent,cycle)
    end

    return_matrix[0] = parent
    return_matrix[1] = cycle
    return_matrix
  end


  def self.dfs_within_graph(current, white_set, gray_set, black_set, graph,parent,cycle)
    move_vertex(current, white_set, gray_set)
    neighbours = graph[current]
    neighbours.each do |neighbor|
      if gray_set.member?(neighbor) # a cycle detected
        if neighbor!=current
          parent[current] = neighbor
          cycle[current] = true
          puts "There is a cycle involving node " + neighbor.to_s
        end
      end
      if white_set.member?(neighbor)
        dfs_within_graph(neighbor, white_set, gray_set, black_set,graph,parent,cycle)
      end

    end
    move_vertex(current, gray_set, black_set)
  end

  
  def self.move_vertex(current, source_set, destination_set)
    source_set.delete(current)
    destination_set.add(current)
  end
  # Begin Changes ==== Create a method to do DFS on the graph and return nodes for which there is a cycle and parent array

  def self.get_cycle_of_size_n(parent,cycle,n)
    output_cycle_list = [[]]
    list_n = []
    cycle.each do |node|
      temp_node = node[0]
      count = 0
      while parent[temp_node] != -1
        if(count>n)
          break
        end
        count += 1
        list_n<<parent[temp_node]
        temp_node = parent[temp_node]
      end
      if count == n
        output_cycle_list<<list_n
      end
      list_n.clear
    end
    output_cycle_list
  end
end
