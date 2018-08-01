# new class created to handle code related to cycles between reviews
# This code was previously in AssignmentParticipant and is not being used anywhere yet
class CollusionCycle
  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given by to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.

  def n_node_cycles(assignment_participant, n)
    collusion_cycles = []
    nodes = Array.new(n)
    find_collusion_cycles(assignment_participant, 0, nodes, collusion_cycles)
    collusion_cycles
  end

  def find_collusion_cycles(assignment_participant, i, nodes, collusion_cycles)
    nodes[i] = assignment_participant
    if i >= nodes.length - 1
      return unless nodes[i].reviewers.include?(nodes[0])

      collusion_cycle = get_collusion_cycle(nodes)
      collusion_cycles.push(collusion_cycle) unless collusion_cycle.nil?
    else
      nodes[i].reviewers.each do |ap|
        find_collusion_cycles(ap, i + 1, nodes, collusion_cycles)
      end
    end
  end

  def get_collusion_cycle(nodes)
    collusion_cycle = []
    (0...nodes.length).each do |i|
      j = (i + 1) % nodes.length
      return nil if nodes[i].reviews_by_reviewer(nodes[j]).nil?
      sjk = nodes[i].reviews_by_reviewer(nodes[j]).total_score

      collusion_cycle.push([nodes[i], sjk])
    end
    collusion_cycle
  end

  # Per cycle
  def cycle_similarity_score(cycle)
    similarity_score = 0.0
    count = 0.0
    (0...cycle.size - 1).each do |pivot|
      pivot_score = cycle[pivot][1]
      (pivot + 1...cycle.size).each do |other|
        similarity_score += (pivot_score - cycle[other][1]).abs
        count += 1.0
      end
    end
    similarity_score /= count unless count == 0.0
    similarity_score
  end

  # Per cycle
  def cycle_deviation_score(cycle)
    deviation_score = 0.0
    count = 0.0
    (0...cycle.size).each do |member|
      participant = AssignmentParticipant.find(cycle[member][0].id)
      total_score = participant.review_score
      deviation_score += (total_score - cycle[member][1]).abs
      count += 1.0
    end
    deviation_score /= count unless count == 0.0
    deviation_score
  end
end
