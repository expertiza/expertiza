#OSS808 Change 28/10/2013
#new class created to handle code related to cycles between reviews
#This code was previously in AssignmentParticipant and is not being used anywhere yet
class CollusionCycle
  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given by to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.
  belongs_to :assignment_participant
  #OSS808 Change 27/10/2013
  #Method renamed to two_node_cycles from get_two_node_cycles
  def two_node_cycles
    collusion_cycles = []
    assignment_participant.get_reviewers.each do |ap|
      if ap.get_reviewers.include?(assignment_participant)
        assignment_participant.reviews_by_reviewer(ap).nil? ? next : s01 = assignment_participant.reviews_by_reviewer(ap).get_total_score
        ap.reviews_by_reviewer(assignment_participant).nil? ? next : s10 = ap.get_reviews_by_reviewer(assignment_participant).get_total_score
        collusion_cycles.push([[assignment_participant, s01], [ap, s10]])
      end
    end
    return collusion_cycles
  end

  #OSS808 Change 27/10/2013
  #Method renamed to three_node_cycles from get_three_node_cycles
  def three_node_cycles
    collusion_cycles = []
    assignment_participant.get_reviewers.each do |ap1|
      ap1.get_reviewers.each do |ap2|
        if ap2.get_reviewers.include?(assignment_participant)
          assignment_participant.reviews_by_reviewer(ap1).nil? ? next : s01 = assignment_participant.reviews_by_reviewer(ap1).get_total_score
          ap1.reviews_by_reviewer(ap2).nil? ? next : s12 = ap1.get_reviews_by_reviewer(ap2).get_total_score
          ap2.reviews_by_reviewer(assignment_participant).nil? ? next : s20 = ap2.get_reviews_by_reviewer(assignment_participant).get_total_score
          collusion_cycles.push([[assignment_participant, s01], [ap1, s12], [ap2, s20]])
        end
      end
    end
    return collusion_cycles
  end

  #OSS808 Change 27/10/2013
  #Method renamed to four_node_cycles from get_four_node_cycles

  def four_node_cycles
    collusion_cycles = []
    assignment_participant.get_reviewers.each do |ap1|
      ap1.get_reviewers.each do |ap2|
        ap2.get_reviewers.each do |ap3|
          if ap3.get_reviewers.include?(assignment_participant)
            assignment_participant.reviews_by_reviewer(ap1).nil? ? next : s01 = assignment_participant.reviews_by_reviewer(ap1).get_total_score
            ap1.reviews_by_reviewer(ap2).nil? ? next : s12 = ap1.get_reviews_by_reviewer(ap2).get_total_score
            ap2.reviews_by_reviewer(ap3).nil? ? next : s23 = ap2.get_reviews_by_reviewer(ap3).get_total_score
            ap3.reviews_by_reviewer(assignment_participant).nil? ? next : s30 = ap3.get_reviews_by_reviewer(assignment_participant).get_total_score
            collusion_cycles.push([[assignment_participant, s01], [ap1, s12], [ap2, s23], [ap3, s30]])
          end
        end
      end
    end
    return collusion_cycles
  end

  #OSS808 Change 28/10/2013
  #Method renamed to cycle_similarity_score from get_cycle_similarity_score
  # Per cycle
  def cycle_similarity_score(cycle)
    similarity_score = 0.0
    count = 0.0
    for pivot in 0 ... cycle.size-1 do
      pivot_score = cycle[pivot][1]
      # puts "Pivot:" + cycle[pivot][1].to_s
      for other in pivot+1 ... cycle.size do
        # puts "Other:" + cycle[other][1].to_s
        similarity_score = similarity_score + (pivot_score - cycle[other][1]).abs
        count = count + 1.0
      end
    end
    similarity_score = similarity_score / count unless count == 0.0
    return similarity_score
  end

  #OSS808 Change 28/10/2013
  #Method renamed to cycle_deviation_score from get_cycle_deviation_score
  # Per cycle
  def cycle_deviation_score(cycle)
    deviation_score = 0.0
    count = 0.0
    for member in 0 ... cycle.size do
      participant = AssignmentParticipant.find(cycle[member][0].id)
      total_score = participant.review_score
      deviation_score = deviation_score + (total_score - cycle[member][1]).abs
      count = count + 1.0
    end
    deviation_score = deviation_score / count unless count == 0.0
    return deviation_score
  end

end