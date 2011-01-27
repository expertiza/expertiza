module DynamicReviewAssignmentHelper

  #  * The article was not written by the potential reviewer.
  #  * The article was not already reviewed by the potential reviewer.
  #  * The article is not on the same topic as the potential reviewer has previously written about.
  #  * The article does not already have the maximum number of potential reviews in progress.
  #  * The article has the minimum number of reviews for that assignment.

  def self.review_assignment(assignment_id, reviewer_id, topic_id, review_type )
     @assignment_id = assignment_id
     @current_assignment = Assignment.find(assignment_id)
     @reviewer_id = reviewer_id
     @topic_id = topic_id
 
     if( review_type == Assignment::RS_AUTO_SELECTED)
       return auto_selected_review_assignment( )
     elsif (review_type == Assignment::RS_STUDENT_SELECTED)
       return student_selected_review_assignment( )
     else
       return nil
     end
   end 
   
   def self.auto_selected_review_assignment( )
     
     # Get all the submissions available
     candidates_for_review = find_submissions_in_current_cycle()

     # Find the most suited submission which is ready for review based on round robin
     return find_submission_to_review( candidates_for_review )
   end
   
   def self.student_selected_review_assignment( )
         
     # Get all the submissions available
     @submissions_in_current_cycle = find_submissions_in_current_cycle()
     # Based on round robin , build a Map ( paricipant_id , {0/1/-1} )
     # The submissions in current cycle is already a sorted Map ( paricipant_id , review_count)
     # Once a submission is picked , it has a higher review count and thus until all the
     # existing submissions reach the same number , it is unavailable. If the review_count reaches the max #reviews required
     #  it is not available . ( 0 - available , 1 - currently not available & -1 not available)
     
     return build_submissions_availability()
   end
 
   # Max no of reviews ? currently assuming 5 
   # The first element will have the least_review_count (as it is sorted) 
   # based on this build the Map
   
   def self.build_submissions_availability()
     least_review_count = -1;
     max_no_reviews = 5
     @submissions_availability = Hash.new
     unless @submissions_in_current_cycle.nil?
       @submissions_in_current_cycle.each { |submission|
 
         if( least_review_count == -1)
           least_review_count = submission[1]
         end
         if submission[0] != @reviewer_id
           @submissions_availability[submission[0]] = get_state(least_review_count,submission[1],max_no_reviews)
         end
       }
     end
     return @submissions_availability
   end
      
   # The current submissions are sorted , it the #review_count == max_review_count 
   # it is not available and similarly #review_count > #least_review_count Currently 
   # not avaliable , else equal available.
       
   def self.get_state(least_review_count,current_review_count,max_review_count)
     if(current_review_count != -1 && current_review_count == max_review_count)
       return -1
     elsif(current_review_count != -1 && current_review_count > least_review_count)
       return 1
     elsif(current_review_count != -1 && current_review_count == least_review_count)
       return 0
     end
   end 

  # Find all the submissions for this cycle
  # Build a Map from  (participant_id  => review_count)
  def self.find_submissions_in_current_cycle()

    #
    #  If the user selected a topic, then filter by that topic first to get a list of all
    #  submissions that have been made for this particular assignment. The 'AssignmentParticipant'
    #  model represents a submission for an assignment (among other things).
    #

    #  Make sure to filter out any submissions that do not have any related material. This avoids
    #  wasting time on submissions that have no content as well as avoiding duplicate reviews
    #  of team submissions.
    conditions_str = "submitted_hyperlink IS NOT NULL OR submitted_at IS NOT NULL"
    if @topic_id.blank?
      submissions_in_current_cycle = AssignmentParticipant.find_all_by_parent_id(@assignment_id,
                                                                                 :conditions => conditions_str)
    else
      submissions_in_current_cycle = AssignmentParticipant.find_all_by_topic_id_and_parent_id(@topic_id ,
                                                                                              @assignment_id,
                                                                                              :conditions => conditions_str)
    end

    #  Create a new Hash to store the number of reviews that have already been done (or are in progress) for
    #  each submission.
    @submission_review_count = Hash.new
    submissions_in_current_cycle.each do |submission|
      # Each 'ResponseMap' entry indicates a review has been performed or is in progress.
      existing_maps = ResponseMap.find_all_by_reviewee_id_and_reviewed_object_id( submission.id, @assignment_id )
      if existing_maps.nil?
        @submission_review_count[submission.id] = 0 # There are no reviews in progress (potential or completed).
      else
        @submission_review_count[submission.id] = existing_maps.size
      end
    end

    # Sort and return the list of submissions by the number of reviews that they have.
    sorted_review_count =  @submission_review_count.sort {|a, b| a[1]<=>b[1]}
    return sorted_review_count
  end

  #
  #  Sort the {submission => review_count} pair
  #  return the first submission that does not violate the conditions
  #  After sorting, we have submissions with least review count at the top.
  #  we can return the submission that does not violate the condition.
  #
  def self.find_submission_to_review( candidates_for_review )

    #  If there are no submissions ready for review, then return nil.
    if candidates_for_review.size == 0
      return nil
    end

    #  Go through the list of submissions that are candidates for review and return the
    #  first one that meets all of the specified criteria.
    candidates_for_review.each do |candidate_submission|
      submission_to_review = is_candidate_submission_valid_for_review(candidate_submission[0],
                                                                      @assignment_id,
                                                                      @reviewer_id)
      #  If this candidate passed all of the checks, then it should
      #  be reviewed.
      if !submission_to_review.nil?
        return submission_to_review
      end
    end

    #  No candidates were found to review.
    return nil
  end

  #  Determine if the given submission can be reviewed by the current
  #  reviewer.
  def self.is_candidate_submission_valid_for_review(submission_id, assignment_id, reviewer_id)
    submission = AssignmentParticipant.find_by_id_and_parent_id(submission_id, assignment_id)

    #  If the submission was done by the reviewer, then do not continue.
    if submission.id == reviewer_id
      return nil
    end

    #  If the submission was already reviewed by the reviewer, then do not continue.
    if !ResponseMap.find_by_reviewed_object_id_and_reviewer_id_and_reviewee_id( submission.parent_id,
                                                                                reviewer_id,
                                                                                submission.id ).nil?
      return nil
    end

    #  Found a valid submission, return it.
    return submission
  end

end
