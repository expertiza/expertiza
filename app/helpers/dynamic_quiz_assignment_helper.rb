# TODO: Remove this helper, this code is not well-designed.
# Look at Assignment.contributor_to_review() as an example of a better approach
module DynamicQuizAssignmentHelper

  #  * The article was not written by the potential reviewer.
  #  * The article was not already reviewed by the potential reviewer.
  #  * The article is not on the same topic as the potential reviewer has previously written about.
  #  * The article does not already have the maximum number of potential reviews in progress.
  #  * The article has the minimum number of reviews for that assignment.

  def self.quiz_assignment(assignment_id, reviewer_id, questionnaire_id, quiz_type )
    @assignment_id = assignment_id
    @current_assignment = Assignment.find(assignment_id)
    @reviewer_id = reviewer_id
    @questionnaire_id = questionnaire_id

    if (quiz_type == Assignment::RS_STUDENT_SELECTED)
      @questionnaires = Array.new
      @questionnaires << Questionnaire.find(@questionnaire_id)#student_selected_quiz_assignment( )
      return @questionnaires
    else
      return nil
    end
  end

  def self.student_selected_quiz_assignment( )

    # Get all the submissions available
    @submissions_in_current_cycle = find_submissions_in_current_cycle()
    # Based on round robin , build a Map ( paricipant_id , {0/1/-1} )
    # The submissions in current cycle is already a sorted Map ( paricipant_id , quiz_count)
    # Once a submission is picked , it has a higher review count and thus until all the
    # existing submissions reach the same number , it is unavailable. If the quiz_count reaches the max #reviews required
    #  it is not available . ( 0 - available , 1 - currently not available & -1 not available)

    return build_submissions_availability()
  end

  # Max no of reviews ? currently assuming 5
  # The first element will have the least_quiz_count (as it is sorted)
  # based on this build the Map

  def self.build_submissions_availability()
    least_quiz_count = -1;
    max_no_reviews = 5
    @submissions_availability = Hash.new
    unless @submissions_in_current_cycle.nil?
      @submissions_in_current_cycle.each { |submission|

        if( least_quiz_count == -1)
          least_quiz_count = submission[1]
        end
        if submission[0] != @reviewer_id
          @submissions_availability[submission[0]] = get_state(least_quiz_count,submission[1],max_no_reviews)
        end
      }
    end
    return @submissions_availability
  end

  # The current submissions are sorted , it the #quiz_count == max_quiz_count
  # it is not available and similarly #quiz_count > #least_quiz_count Currently
  # not avaliable , else equal available.

  def self.get_state(least_quiz_count,current_quiz_count,max_quiz_count)
    if(current_quiz_count != -1 && current_quiz_count == max_quiz_count)
      return -1
    elsif(current_quiz_count != -1 && current_quiz_count > least_quiz_count)
      return 1
    elsif(current_quiz_count != -1 && current_quiz_count == least_quiz_count)
      return 0
    end
  end

  # Find all the submissions for this cycle
  # Build a Map from  (participant_id  => quiz_count)
  def self.find_submissions_in_current_cycle()

    #
    #  If the user selected a topic, then filter by that topic first to get a list of all
    #  submissions that have been made for this particular assignment. The 'AssignmentParticipant'
    #  model represents a submission for an assignment (among other things).
    #

    #  Make sure to filter out any submissions that do not have any related material. This avoids
    #  wasting time on submissions that have no content as well as avoiding duplicate reviews
    #  of team submissions.
    #if @questionnaire_id.blank?
    submissions_in_current_cycle = AssignmentParticipant.where(parent_id: @assignment_id)
    #else
    #  submissions_in_current_cycle = AssignmentParticipant.where(questionnaire_id: @questionnaire_id,
    #                                                                                          parent_id: @assignment_id)
    #end
    #submissions_in_current_cycle.reject! { |submission| !submission.has_submissions? }

    #  Create a new Hash to store the number of reviews that have already been done (or are in progress) for
    #  each submission.
    @submission_quiz_count = Hash.new
    submissions_in_current_cycle.each do |submission|
      # Each 'ResponseMap' entry indicates a review has been performed or is in progress.
      existing_maps = ResponseMap.where(reviewee_id:  submission.id, reviewed_object_id: @assignment_id )
      if existing_maps.nil?
        @submission_quiz_count[submission.id] = 0 # There are no reviews in progress (potential or completed).
      else
        @submission_quiz_count[submission.id] = existing_maps.size
        end
    end

    # Sort and return the list of submissions by the number of reviews that they have.
    sorted_quiz_count =  @submission_quiz_count.sort {|a, b| a[1]<=>b[1]}
    return sorted_quiz_count
  end

  end
