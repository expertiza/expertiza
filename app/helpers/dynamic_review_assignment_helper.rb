# TODO: Remove this helper, this code is not well-designed.
# Look at Assignment.contributor_to_review() as an example of a better approach
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
 
     if (review_type == Assignment::RS_STUDENT_SELECTED)
       return student_selected_review_assignment( )
     else
       return nil
     end
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
    if @topic_id.blank?
      submissions_in_current_cycle = AssignmentParticipant.find_all_by_parent_id(@assignment_id)
    else
      submissions_in_current_cycle = AssignmentParticipant.find_all_by_topic_id_and_parent_id(@topic_id ,
                                                                                              @assignment_id)
    end
    submissions_in_current_cycle.reject! { |submission| !submission.has_submissions? }
    
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

end
