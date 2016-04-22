#new class created to handle code related to cycles between reviews
#This code was previously in AssignmentParticipant and is not being used anywhere yet
class CollusionCycle < ActiveRecord::Base
  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given by to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.

  # def two_node_cycles
  #   collusion_cycles = []
  #   assignment_participant.reviewers.each do |ap|
  #     if ap.reviewers.include?(assignment_participant)
  #       if assignment_participant.reviews_by_reviewer(ap).nil?
  #         next
  #       else
  #         s01 = assignment_participant.reviews_by_reviewer(ap).get_total_score
  #       end
  #
  #       if ap.reviews_by_reviewer(assignment_participant).nil?
  #         next
  #       else
  #         s10 = ap.reviews_by_reviewer(assignment_participant).get_total_score
  #       end
  #
  #       collusion_cycles.push([[assignment_participant, s01], [ap, s10]])
  #     end
  #   end
  #   collusion_cycles
  # end
  #
  # def three_node_cycles
  #   collusion_cycles = []
  #   assignment_participant.reviewers.each do |ap1|
  #     ap1.reviewers.each do |ap2|
  #       if ap2.reviewers.include?(assignment_participant)
  #         if assignment_participant.reviews_by_reviewer(ap1).nil?
  #           next
  #         else
  #           s01 = assignment_participant.reviews_by_reviewer(ap1).get_total_score
  #         end
  #
  #         if ap1.reviews_by_reviewer(ap2).nil?
  #           next
  #         else
  #           s12 = ap1.reviews_by_reviewer(ap2).get_total_score
  #         end
  #
  #         if ap2.reviews_by_reviewer(assignment_participant).nil?
  #           next
  #         else
  #           s20 = ap2.reviews_by_reviewer(assignment_participant).get_total_score
  #         end
  #         collusion_cycles.push([[assignment_participant, s01], [ap1, s12], [ap2, s20]])
  #       end
  #     end
  #   end
  #
  #   collusion_cycles
  # end
  #
  # def four_node_cycles
  #   collusion_cycles = []
  #   assignment_participant.reviewers.each do |ap1|
  #     ap1.reviewers.each do |ap2|
  #       ap2.reviewers.each do |ap3|
  #         if ap3.reviewers.include?(assignment_participant)
  #
  #           if assignment_participant.reviews_by_reviewer(ap1).nil?
  #             next
  #           else
  #             s01 = assignment_participant.reviews_by_reviewer(ap1).get_total_score
  #           end
  #
  #           if ap1.reviews_by_reviewer(ap2).nil?
  #             next
  #           else
  #             s12 = ap1.reviews_by_reviewer(ap2).get_total_score
  #           end
  #
  #           if ap2.reviews_by_reviewer(ap3).nil?
  #             next
  #           else
  #             s23 = ap2.reviews_by_reviewer(ap3).get_total_score
  #           end
  #
  #           if ap3.reviews_by_reviewer(assignment_participant).nil?
  #             next
  #           else
  #             s30 = ap3.reviews_by_reviewer(assignment_participant).get_total_score
  #           end
  #
  #           collusion_cycles.push([[assignment_participant, s01], [ap1, s12], [ap2, s23], [ap3, s30]])
  #         end
  #       end
  #     end
  #   end
  #   collusion_cycles
  # end
  #
  # # Per cycle
  # def cycle_similarity_score(cycle)
  #   similarity_score = 0.0
  #   count = 0.0
  #   for pivot in 0 ... cycle.size-1 do
  #     pivot_score = cycle[pivot][1]
  #     for other in pivot+1 ... cycle.size do
  #       similarity_score = similarity_score + (pivot_score - cycle[other][1]).abs
  #       count = count + 1.0
  #     end
  #   end
  #   similarity_score = similarity_score / count unless count == 0.0
  #   similarity_score
  # end
  #
  # # Per cycle
  # def cycle_deviation_score(cycle)
  #   deviation_score = 0.0
  #   count = 0.0
  #   for member in 0 ... cycle.size do
  #     participant = AssignmentParticipant.find(cycle[member][0].id)
  #     total_score = participant.review_score
  #     deviation_score = deviation_score + (total_score - cycle[member][1]).abs
  #     count = count + 1.0
  #   end
  #   deviation_score = deviation_score / count unless count == 0.0
  #   deviation_score
  # end



  #Begin Changes ==== Create a method to make a graph
  def self.get_review_response_map(assignment)
    # create object for response map
    graph = Hash.new
    # @response_maps = ResponseMap.find_by_reviewed_object_id(assignment)
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

  def self.get_user_from_reviewer(reviewer)
    @user = AssignmentParticipant.find(reviewer).user
    @user.id
  end

  def self.get_user_from_reviewee(reviewee)
    #reviewee is the team here get all the members of the team and put them in the adjacency list
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

  #Implementation of the DFS and collusion detection
  # def cycle_detection (graph, n)
  #   white_set = set.new
  #   gray_set = set.new
  #   black_set = set.new
  #   # vertex = vertex (graph) # get all the vertex from graph
  #   vertex = graph
  #   vertex.each do |current, neighbours|
  #     dfs_within_n (current, white_set, gray_set, black_set, [], n, neighbours)
  #   end
  # end

  # def dfs_within_n (current, white_set, gray_set, black_set, recent_n_vertex, n, neighbours)
  #   move_vertex (current, white_set, gray_set)
  #   # neighbours = neighbours(current)
  #   neighbors.each do |neighbor|
  #     if black_set.contains(neighbor)
  #       continue
  #     end
  #     if gray_set.contains(neighbor) # a cycle detected
  #       if recent_n_vertex.contains(current) # a cycle within n vertex detected
  #         output_loop (recent_n_vertex, current)
  #       end
  #     end
  #     if recent_n_vertex.length==n
  #       recent_n_vertex.remove[0]
  #     end
  #     recent_n_vertex.add(neighbor)
  #     dfs_within_n (current, white_set, gray_set, black_set, recent_n_vertex, n, neighbours)
  #   end
  #   move_vertex (current, gray_set, black_set)
  # end
  #
  # def move_vertex(current, source_set, destination_set)
  #   source_set.remove(current)
  #   destination_set.add(current)
  # end

end
