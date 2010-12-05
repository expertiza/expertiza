module DynamicReviewAssignmentHelper

  #  * The article was not written by the potential reviewer.
  #  * The article was not already reviewed by the potential reviewer.
  #  * The article is not on the same topic as the potential reviewer has previously written about.
  #  * The article does not already have the maximum number of potential reviews in progress.
  #  * The article has the minimum number of reviews for that assignment.

  def self.review_assignment(assignment_id , reviewer_id , topic_id, review_type )
     @assignment_id = assignment_id
     @current_assignment = Assignment.find(assignment_id)
     @reviewer_id = reviewer_id
     @topic_id = topic_id
 
     if( review_type == "dynamic")
      return dynamic_review_assignment(assignment_id , reviewer_id , topic_id)
     elsif (review_type == "self")
      return self_review_assignment(assignment_id , reviewer_id , topic_id)
     end
   end 
   
   def self.dynamic_review_assignment(assignment_id , reviewer_id , topic_id)
     
     # Check if any of the reserved submissions have passed the allocated time , if yes remove the record
     remove_all_expired_reservations()
 
     # Get all the submissions available
     @submissions_in_current_cycle = find_submissions_in_current_cycle()
     @submissions_in_progress = find_reviews_in_progress()
 
     # Find the most suited submission which is ready for review based on round robin
     find_submission_to_review()
   end
   
   def self.self_review_assignment(assignment_id , reviewer_id , topic_id)
         
     # Get all the submissions available
     @submissions_in_current_cycle = find_submissions_in_current_cycle()
     puts @submissions_in_current_cycle
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
     if(@submissions_in_current_cycle.nil? == false &&  @submissions_in_current_cycle.size > 0)
       @submissions_in_current_cycle.each { |submission|
 
         if( least_review_count == -1)
           least_review_count = submission[1]
         end
         if submission[0] != @reviewer_id # Check for more conditions here
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

  #
  #  Removes all dynamic response mappings that have expired.
  #  NOTE: This is not assignment specific, and clears ALL expired potential responses.
  #
  def self.remove_all_expired_reservations()
    mappings_to_delete = ResponseMap.find(:all, :conditions => ["potential_response_deadline IS NOT NULL and potential_response_deadline < ?", DateTime.now])
    mappings_to_delete.each { |rm| rm.delete }
  end
 
  # Find all the submissions for this cycle
  # Build a Map from  (participant_id  => review_count)
  # TODO On Max no of Reviews ,  no longer can be reviewed
  def self.find_submissions_in_current_cycle()
    if @topic_id.blank?
      submissions_in_current_cycle = AssignmentParticipant.find_all_by_parent_id(@assignment_id)
    else
      submissions_in_current_cycle = AssignmentParticipant.find_all_by_topic_id_and_parent_id(@topic_id , @assignment_id)
    end

    @submission_review_count = Hash.new
    submissions_in_current_cycle.each do |submission| 
      existing_maps = ResponseMap.find_all_by_reviewee_id_and_reviewed_object_id( submission.id, @assignment_id )
      if existing_maps.nil?
        @submission_review_count[submission.id] = 0 # There are no reviews in progress (potential or completed).
      else
        @submission_review_count[submission.id] = existing_maps.size
      end
    end
    sorted_review_count =  @submission_review_count.sort {|a, b| a[1]<=>b[1]}
    return sorted_review_count
  end

  # Find all the submissions that are in progress
  # build a list of [ResponseMap.reviewed_object_id]
  def self.find_reviews_in_progress()
    review_in_progress  = Array.new
    submission_in_progress =  ResponseMap.find(:all, :conditions => ["potential_response_deadline IS NOT NULL and reviewed_object_id = ?", @assignment_id])
    submission_in_progress.each do |in_progress|
      review_in_progress << in_progress.reviewed_object_id
    end
    return review_in_progress
  end

  #  Sort the {submission => review_count} pair
  #  return the first submission that does not violate the conditions
  #  After sorting, we have submissions with least review count at the top.
  #  we can return the submission that does not violate the condition.
  #TODO
  # You cannot review your own submission
  # The submission is currently on hold for review
  def self.find_submission_to_review()
    unless @submissions_in_current_cycle.blank?
      @submissions_in_current_cycle.each do |submission|
        if submission[0] != @reviewer_id # TODO Check for the rest of the conditions here
          @submission_ready = submission[0]
          break
        end
      end
    end
    return AssignmentParticipant.find_by_id_and_parent_id(@submission_ready,@assignment_id)
  end
end
