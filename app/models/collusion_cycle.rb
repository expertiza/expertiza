#new class created to handle code related to cycles between reviews
#This code was previously in AssignmentParticipant and is not being used anywhere yet
class CollusionCycle
  # Cycle data structure
  # Each edge of the cycle stores a participant and the score given by to the participant by the reviewer.
  # Consider a 3 node cycle: A --> B --> C --> A (A reviewed B; B reviewed C and C reviewed A)
  # For the above cycle, the data structure would be: [[A, SCA], [B, SAB], [C, SCB]], where SCA is the score given by C to A.

  def two_node_cycles
    collusion_cycles = []
    assignment_participant.get_reviewers.each do |ap|
      if ap.get_reviewers.include?(assignment_participant)
        if assignment_participant.reviews_by_reviewer(ap).nil?
          next
        else
          s01 = assignment_participant.reviews_by_reviewer(ap).get_total_score
        end

        if ap.reviews_by_reviewer(assignment_participant).nil?
          next
        else
          s10 = ap.reviews_by_reviewer(assignment_participant).get_total_score
        end

        collusion_cycles.push([[assignment_participant, s01], [ap, s10]])
      end
    end
    collusion_cycles
  end

  def three_node_cycles
    collusion_cycles = []
    assignment_participant.get_reviewers.each do |ap1|
      ap1.get_reviewers.each do |ap2|
        if ap2.get_reviewers.include?(assignment_participant)
          if assignment_participant.reviews_by_reviewer(ap1).nil?
            next
          else
            s01 = assignment_participant.reviews_by_reviewer(ap1).get_total_score
          end

          if ap1.reviews_by_reviewer(ap2).nil?
            next
          else
            s12 = ap1.reviews_by_reviewer(ap2).get_total_score
          end

          if ap2.reviews_by_reviewer(assignment_participant).nil?
            next
          else
            s20 = ap2.reviews_by_reviewer(assignment_participant).get_total_score
          end
          collusion_cycles.push([[assignment_participant, s01], [ap1, s12], [ap2, s20]])
        end
      end
    end

    collusion_cycles
  end

  def four_node_cycles
    collusion_cycles = []
    assignment_participant.get_reviewers.each do |ap1|
      ap1.get_reviewers.each do |ap2|
        ap2.get_reviewers.each do |ap3|
          if ap3.get_reviewers.include?(assignment_participant)

            if assignment_participant.reviews_by_reviewer(ap1).nil?
              next
            else
              s01 = assignment_participant.reviews_by_reviewer(ap1).get_total_score
            end

            if ap1.reviews_by_reviewer(ap2).nil?
              next
            else
              s12 = ap1.reviews_by_reviewer(ap2).get_total_score
            end

            if ap2.reviews_by_reviewer(ap3).nil?
              next
            else
              s23 = ap2.reviews_by_reviewer(ap3).get_total_score
            end

            if ap3.reviews_by_reviewer(assignment_participant).nil?
              next
            else
              s30 = ap3.reviews_by_reviewer(assignment_participant).get_total_score
            end

            collusion_cycles.push([[assignment_participant, s01], [ap1, s12], [ap2, s23], [ap3, s30]])
          end
        end
      end
    end
    collusion_cycles
  end

  # Per cycle
  def cycle_similarity_score(cycle)
    similarity_score = 0.0
    count = 0.0
    for pivot in 0 ... cycle.size-1 do
      pivot_score = cycle[pivot][1]
      for other in pivot+1 ... cycle.size do
        similarity_score = similarity_score + (pivot_score - cycle[other][1]).abs
        count = count + 1.0
      end
    end
    similarity_score = similarity_score / count unless count == 0.0
    similarity_score
  end

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
    deviation_score
  end

end
