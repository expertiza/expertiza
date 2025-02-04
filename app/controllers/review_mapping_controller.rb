class ReviewMappingController < ApplicationController
  include ReviewMappingHelper, AuthorizationHelper
   
  autocomplete :user, :name
  # helper :dynamic_review_assignment
  helper :submitted_content
  # including the following helper to refactor the code in response_report function
  # include ReportFormatterHelper

  @@time_create_last_review_mapping_record = nil

  # E1600
  # start_self_review is a method that is invoked by a student user so it should be allowed accordingly
  def action_allowed?
    case params[:action]
    when 'add_dynamic_reviewer',
          'show_available_submissions',
          'assign_reviewer_dynamically',
          'assign_metareviewer_dynamically',
          'assign_quiz_dynamically',
          'start_self_review'
      true
    else ['Instructor', 'Teaching Assistant', 'Administrator'].include? current_role_name
    end
  end

  def add_calibration
    participant = find_assignment_participant(session[:user].id, params[:id])
    if participant.nil?
      participant = AssignmentParticipant.create(parent_id: params[:id], user_id: session[:user].id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
    end
    map = find_review_response_mapping(params[:id], participant, params[:team_id], true)

    if map.nil?
      map = ReviewResponseMap.create(reviewed_object_id: params[:id], reviewer_id: participant.get_reviewer.id, reviewee_id: params[:team_id], calibrate_to: true) if map.nil?
    end
    redirect_to controller: 'response', action: 'new', id: map.id, assignment_id: params[:id], return: 'assignment_edit'
  end


  def select_reviewer
    @contributor = AssignmentTeam.find(params[:contributor_id])
    session[:contributor] = @contributor
  end

  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])
  end


  #EDITED: If the user is invalid(not present in database), then return with error message.
  #If reviewer is a participant of the assignment, then only move forward with reviewer assignment.
  #Work Done: Refactored add_reviewer and extracted some code to make it smaller.
  def add_reviewer
    assignment = find_assignment(params[:id])
    topic_id = params[:topic_id]
    user_id = if User.where(name: params[:user][:name]).first
      then User.where(name: params[:user][:name]).first.id
      else nil
      end
    if user_id.nil?
      flash[:error] = 'The user does not exist.'
      redirect_to action: 'list_mappings', id: assignment.id, msg: 'The user does not exist.'
      return
    end
    # If instructor wants to assign one student to review his/her own artifact,
    # it should be counted as "self-review" and we need to make /app/views/submitted_content/_selfreview.html.erb work.
    if is_self_review?(params[:contributor_id], user_id)
      flash[:error] = 'You cannot assign this student to review his/her own artifact.'
      redirect_to action: 'list_mappings', id: assignment.id
      return
    end
    # Team lazy initialization
    SignUpSheet.signup_team(assignment.id, user_id, topic_id)
    msg = ''
    begin
      user = User.from_params(params)
      # Assign the reviewer to the contributor
      assign_reviewer_to_contributor(user, assignment, params[:contributor_id], topic_id)
    rescue StandardError => e
      msg = e.message
    end

    redirect_to action: 'list_mappings', id: assignment.id, msg: msg
  end
  def add_metareviewer
    mapping = ResponseMap.find(params[:id])
    msg = ''
    begin
      user = User.from_params(params)

      regurl = url_for action: 'add_user_to_assignment', id: mapping.map_id, user_id: user.id
      reviewer = get_reviewer(user, mapping.assignment, regurl)
      unless MetareviewResponseMap.where(reviewed_object_id: mapping.map_id, reviewer_id: reviewer.id).first.nil?
        raise 'The metareviewer "' + reviewer.user.name + '" is already assigned to this reviewer.'
      end

      MetareviewResponseMap.create(reviewed_object_id: mapping.map_id,
                                   reviewer_id: reviewer.id,
                                   reviewee_id: mapping.reviewer.id)
    rescue StandardError => e
      msg = e.message
    end
    redirect_to action: 'list_mappings', id: mapping.assignment.id, msg: msg
  end

  #ADDED: Assigns team with a topic to reviewer dynamically
  # @param topic_id [Integer] The ID of the topic to be assigned
  # @param assignment [Assignment] The current assignment
  # @param reviewer [User] The reviewer being assigned
  # @return [void] No result is returned
  def assignment_with_topics(topic_id, assignment, reviewer)
    topic = assign_topics_to_reviewer(topic_id, reviewer)
    if topic.nil?
      flash[:error] = 'No topics are available to review at this time. Please try later.'
    else
      assignment.assign_reviewer_dynamically(reviewer, topic)
    end
  end

  #ADDED: Assigns team with no topic to reviewer dynamically
  # @param assignment [Assignment] The current assignment
  # @param reviewer [User] The reviewer being assigned
  # @return [void] No result is returned
  def assignment_with_no_topics(assignment, reviewer)
    assignment_team = assign_team_to_review(assignment, reviewer)
    if assignment_team.nil?
      flash[:error] = 'No artifacts are available to review at this time. Please try later.'
    else
      assignment.assign_reviewer_dynamically_no_topic(reviewer, assignment_team)
    end
  end
#Added: Assigns a reviewer to a contributor (team or participant) in the context of an assignment
  # @param user [User] The user being assigned as a reviewer.
  # @param assignment [Assignment] The assignment to which the review is related.
  # @param contributor_id [Integer] The ID of the contributor (team or participant) being reviewed.
  # @param topic_id [Integer] The ID of the topic associated with the review (if applicable).
  # @raise [RuntimeError] Raises an error if the reviewer is already assigned to the contributor.
  # @return [ReviewResponseMap] The newly created review response mapping record.
  def assign_reviewer_to_contributor(user, assignment, contributor_id, topic_id)

    # Generate registration URL
    reg_url = url_for id: assignment.id, user_id: user.id, contributor_id: contributor_id

    # Get the assignment's participant corresponding to the user
    reviewer = get_reviewer(user, assignment, reg_url)

    # Check if reviewer is already assigned
    if ReviewResponseMap.exists?(reviewee_id: contributor_id, reviewer_id: reviewer.id)
      raise "The reviewer, \"#{reviewer.name}\", is already assigned to this contributor."
    else
      ReviewResponseMap.create(
        reviewee_id: contributor_id,
        reviewer_id: reviewer.id,
        reviewed_object_id: assignment.id
      )
    end
  end


  #ADDED : Extracted the logic that decides whether to call assignment_with_topics or assignment_with_no_topics
  # @param assignment [Assignment] The current assignment
  # @param reviewer [User] The reviewer being assigned
  # @return [void] No result is returned
  def assign_reviewer_based_on_topics(assignment, reviewer)
    if assignment.topics?# assignment with topics
      assignment_with_topics(params[:topic_id], assignment, reviewer)
    else
      assignment_with_no_topics(assignment, reviewer)
    end
  end


  #ADDED: Return already assigned topic. If topic is nil, then assign an available topic to the reviewer.
  # @param topic_id [Integer, nil] The ID of the topic (if specified)
  # @param reviewer [User] The reviewer being assigned
  # @return [SignUpTopic or nil] The assigned topic or nil if no topics available
  def assign_topics_to_reviewer(topic_id, reviewer)
    if params[:topic_id]
      SignUpTopic.find(params[:topic_id])
    else
      begin
        assignment.candidate_topics_to_review(reviewer).to_a.sample
      rescue StandardError
        nil
      end
    end
  end

  #ADDED: Assign a reviewer when there are no topics for the assignment.
  # @param assignment [Assignment] The current assignment
  # @param reviewer [User] The reviewer being assigned
  # @return [AssignmentTeam or nil] The assigned team or nil if no teams available
  def assign_team_to_review(assignment, reviewer)
    assignment_teams = assignment.candidate_assignment_teams_to_review(reviewer)
    begin
      assignment_teams.to_a.sample
    rescue StandardError
      nil
    end
  end


  # 7/12/2015 -zhewei
  # This method is used for assign submissions to students for peer review.
  # This method is different from 'assignment_reviewer_automatically', which is in 'review_mapping_controller'
  # and is used for instructor assigning reviewers in instructor-selected assignment.
  # Work Done : Used Guard Clauses to Reduce Nesting- replaced nested if statements with guard clauses that return early if a condition isn't met.
  # Work Done : Introduced function and made code shorter.
  def assign_reviewer_dynamically
    assignment = find_assignment(params[:assignment_id])
    participant = find_assignment_participant(params[:reviewer_id], assignment.id)
    reviewer = participant.get_reviewer

    error_message = nil

    if topic_selection_invalid?(assignment)
      error_message = 'No topic is selected.  Please go back and select a topic.'
    elsif !can_request_additional_reviews?(assignment, reviewer)
      error_message = "You cannot do more than #{assignment.num_reviews_allowed} reviews based on assignment policy."
    elsif !within_outstanding_review_limit?(assignment, reviewer)
      error_message = "You cannot do more reviews when you have #{Assignment.max_outstanding_reviews} reviews to do."
    else
      assign_reviewer_based_on_topics(assignment, reviewer)
    end

    flash[:error] = error_message if error_message

    redirect_to controller: 'student_review', action: 'list', id: participant.id
  end




  # assigns the quiz dynamically to the participant
  def assign_quiz_dynamically
    begin
      assignment = find_assignment(params[:assignment_id])
      reviewer = find_assignment_participant(params[:reviewer_id], assignment.id)
      if ResponseMap.where(reviewed_object_id: params[:questionnaire_id], reviewer_id: params[:participant_id]).first
        flash[:error] = 'You have already taken that quiz.'
      else
        @map = QuizResponseMap.new
        @map.reviewee_id = Questionnaire.find(params[:questionnaire_id]).instructor_id
        @map.reviewer_id = params[:participant_id]
        @map.reviewed_object_id = Questionnaire.find_by(instructor_id: @map.reviewee_id).id
        @map.save
      end
    rescue StandardError => e
      flash[:alert] = e.nil? ? $ERROR_INFO : e
    end
    redirect_to student_quizzes_path(id: reviewer.id)
  end
  def assign_metareviewer_dynamically
    assignment = find_assignment(params[:assignment_id])
    metareviewer = find_assignment_participant(params[:metareviewer_id], assignment.id)
    # this will provide a flash warning instead of page crash when there are no review to Meta review.
    begin
      assignment.assign_metareviewer_dynamically(metareviewer)
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to controller: 'student_review', action: 'list', id: metareviewer.id
  end
  def assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
    #Unsure what this line does.
    # if ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 0)
    #                     .where('created_at > :time',
    #                            time: @@time_create_last_review_mapping_record).size < review_strategy.reviews_needed
    if check_insufficient_reviews(assignment_id, review_strategy)
      participants_with_insufficient_review_num = []
      participants_hash.each do |participant_id, review_num|
        participants_with_insufficient_review_num << participant_id if review_num < review_strategy.reviews_per_student
      end
      unsorted_teams_hash = {}

      ReviewResponseMap.where(reviewed_object_id: assignment_id,
                              calibrate_to: 0).each do |response_map|
        if unsorted_teams_hash.key? response_map.reviewee_id
          unsorted_teams_hash[response_map.reviewee_id] += 1
        else
          unsorted_teams_hash[response_map.reviewee_id] = 1
        end
      end
      teams_hash = unsorted_teams_hash.sort_by { |_, v| v }.to_h

      participants_with_insufficient_review_num.each do |participant_id|
        teams_hash.each_key do |team_id, _num_review_received|
          next if is_self_review?(team_id, Participant.find(participant_id).user_id)

          participant = AssignmentParticipant.find(participant_id)
          ReviewResponseMap.where(reviewee_id: team_id, reviewer_id: participant.get_reviewer.id,
                                  reviewed_object_id: assignment_id).first_or_create

          teams_hash[team_id] += 1
          teams_hash = teams_hash.sort_by { |_, v| v }.to_h
          break
        end
      end
    end
    @@time_create_last_review_mapping_record = ReviewResponseMap
                                               .where(reviewed_object_id: assignment_id)
                                               .last.created_at
  end






  def delete_outstanding_reviewers
    assignment = find_assignment(params[:id])
    #team = AssignmentTeam.find(params[:contributor_id])
    team = find_assignment_team(params[:contributor_id])
    review_response_maps = team.review_mappings
    num_remain_review_response_maps = review_response_maps.size
    review_response_maps.each do |review_response_map|
      unless Response.exists?(map_id: review_response_map.id)
        ReviewResponseMap.find(review_response_map.id).destroy
        num_remain_review_response_maps -= 1
      end
    end
    if num_remain_review_response_maps > 0
      flash[:error] = "#{num_remain_review_response_maps} reviewer(s) cannot be deleted because they have already started a review."
    else
      flash[:success] = "All review mappings for \"#{team.name}\" have been deleted."
    end
    redirect_to action: 'list_mappings', id: assignment.id
  end

  #EDITED: variable change : mmapings to meta_review_mappings
  # @param [Integer] params[:id] - ID of the ResponseMap whose metareview mappings need to be deleted.
  # @param [Boolean] params[:force] - Flag to indicate if deletion should be forced despite existing dependencies.
  # @output:
  #   - Success: "All metareview mappings for contributor X and reviewer Y have been deleted."
  #   - Failure: "A delete action failed: Z metareviews exist for these mappings. Options to delete them anyway."
  # @output Redirects to the 'list_mappings' action for the assignment.
  def delete_all_metareviewers
    mapping = ResponseMap.find(params[:id])
    meta_review_mappings = MetareviewResponseMap.where(reviewed_object_id: mapping.map_id)
    unsuccessful_deletes_count = 0
    meta_review_mappings.each do |meta_review_mappings|
      begin
        meta_review_mappings.delete(ActiveModel::Type::Boolean.new.cast(params[:force]))
      rescue StandardError
        unsuccessful_deletes_count += 1
      end
    end

    if unsuccessful_deletes_count > 0
      url_yes = url_for action: 'delete_all_metareviewers', id: mapping.map_id, force: 1
      url_no = url_for action: 'delete_all_metareviewers', id: mapping.map_id
      flash[:error] = "A delete action failed:<br/>#{unsuccessful_deletes_count} metareviews exist for these mappings. " \
                      'Delete these mappings anyway?' \
                      "&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><br/>"
    else
      flash[:note] = 'All metareview mappings for contributor "' + mapping.reviewee.name + '" and reviewer "' + mapping.reviewer.name + '" have been deleted.'
    end
    redirect_to action: 'list_mappings', id: mapping.assignment.id
  end

  # E1721: Unsubmit reviews using AJAX
  def unsubmit_review
    @response = Response.where(map_id: params[:id]).last
    review_response_map = ReviewResponseMap.find_by(id: params[:id])
    reviewer = review_response_map.reviewer.get_reviewer.name
    reviewee = review_response_map.reviewee.name
    if @response.update_attribute('is_submitted', false)
      flash.now[:success] = 'The review by "' + reviewer + '" for "' + reviewee + '" has been unsubmitted.'
    else
      flash.now[:error] = 'The review by "' + reviewer + '" for "' + reviewee + '" could not be unsubmitted.'
    end
    render action: 'unsubmit_review.js.erb', layout: false
  end
  # E1721 changes End

  def delete_reviewer
    review_response_map = ReviewResponseMap.find_by(id: params[:id])
    if review_response_map && !Response.exists?(map_id: review_response_map.id)
      review_response_map.destroy
      flash[:success] = 'The review mapping for "' + review_response_map.reviewee.name + '" and "' + review_response_map.reviewer.name + '" has been deleted.'
    else
      flash[:error] = 'This review has already been done. It cannot been deleted.'
    end
    redirect_back fallback_location: root_path
  end

  def delete_metareviewer
    meta_review_mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = meta_review_mapping.assignment.id
    flash[:note] = 'The metareview mapping for ' + meta_review_mapping.reviewee.name + ' and ' + meta_review_mapping.reviewer.name + ' has been deleted.'

    begin
      meta_review_mapping.delete
    rescue StandardError
      flash[:error] = 'A delete action failed:<br/>' + $ERROR_INFO.to_s + "<a href='/review_mapping/delete_metareview/" + meta_review_mapping.map_id.to_s + "'>Delete this mapping anyway>?"
    end

    redirect_to action: 'list_mappings', id: assignment_id
  end

  def delete_metareview
    meta_review_mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = meta_review_mapping.assignment.id
    # metareview = mapping.response
    # metareview.delete
    meta_review_mapping.delete
    redirect_to action: 'list_mappings', id: assignment_id
  end

  def list_mappings
    flash[:error] = params[:msg] if params[:msg]
    @assignment = find_assignment(params[:id])
    # ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @items = AssignmentTeam.where(parent_id: @assignment.id)
    @items.sort_by(&:name)
  end

  #ADDED: Creates teams for individual assignment.
  # @param [Array<Participant>] participants - List of participants in the assignment.
  # @param [Array<Team>] teams - List of existing teams to which newly created teams will be added.
  # @param [Integer] assignment_id - The ID of the assignment for which teams are being created.
  # @param [Assignment] assignment - The assignment object containing assignment-related details.
  # @return [Team[]] - Updated list of teams, including newly created teams.
  def create_individual_assignment_team(participants, teams, assignment_id, assignment)
    participants.each do |participant|
      user = participant.user
      next if TeamsUser.team_id(assignment_id, user.id)

      if assignment.auto_assign_mentor
        team = MentoredTeam.create_team_and_node(assignment_id)
      else
        team = AssignmentTeam.create_team_and_node(assignment_id)
      end
      ApplicationController.helpers.create_team_users(user, team.id)
      teams << team
    end
    teams
  end

  def automatic_review_mapping
    assignment_id = params[:id].to_i
    assignment = find_assignment(params[:id])
    participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
    teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
    # Create teams if its an individual assignment.
    if teams.empty? && max_team_size == 1
      teams = create_individual_assignment_team(participants, teams, assignment_id, assignment)
    end
    student_review_num = params[:num_reviews_per_student].to_i
    submission_review_num = params[:num_reviews_per_submission].to_i
    exclude_teams = params[:exclude_teams_without_submission]
    calibrated_artifacts_num = params[:num_calibrated_artifacts].to_i
    uncalibrated_artifacts_num = params[:num_uncalibrated_artifacts].to_i
    if calibrated_artifacts_num.zero? && uncalibrated_artifacts_num.zero?
      # check for exit paths first

     handle_standard_review_mapping(assignment_id,
      participants,
      teams,
      student_review_num,
      submission_review_num,
      exclude_teams
      )

    else
    # Handle calibrated and uncalibrated artifacts

     handle_calibrated_and_uncalibrated_artifacts(
      assignment_id,
      participants,
      teams,
      calibrated_artifacts_num,
      uncalibrated_artifacts_num
      )

    end
    redirect_to action: 'list_mappings', id: assignment_id
  end

  #ADDED: Helper method to handle automatic review mapping when calibrated and uncalibrated artifacts are involved
  # @param [Integer] assignment_id - The ID of the assignment.
  # @param [Participant[]] participants - List of participants who can review.
  # @param [Team[]] teams - List of all teams for the assignment.
  # @param [Integer] calibrated_artifacts_num - Number of reviews to assign for calibrated artifacts.
  # @param [Integer] uncalibrated_artifacts_num - Number of reviews to assign for uncalibrated artifacts.
  # @return [void] - Performs automatic review mapping for both calibrated and uncalibrated artifacts.
  def handle_calibrated_and_uncalibrated_artifacts(assignment_id, participants, teams, calibrated_artifacts_num, uncalibrated_artifacts_num)
    teams_with_calibrated_artifacts = []

    ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 1).each do |response_map|
      teams_with_calibrated_artifacts << AssignmentTeam.find(response_map.reviewee_id)
    end

    teams_with_uncalibrated_artifacts = teams - teams_with_calibrated_artifacts

    # REVIEW: mapping strategy
    # Apply automatic review mapping strategy for teams with calibrated artifacts
    automatic_review_mapping_strategy(
      assignment_id,
      participants,
      teams_with_calibrated_artifacts.shuffle!,
      calibrated_artifacts_num,
      0
    )

    # REVIEW: mapping strategy
    # Since after first mapping, participants (delete_at) will be nil
    participants = AssignmentParticipant.where(parent_id: assignment_id).to_a.select(&:can_review).shuffle!
   # Apply automatic review mapping strategy for teams with uncalibrated artifacts
    automatic_review_mapping_strategy(
      assignment_id,
      participants,
      teams_with_uncalibrated_artifacts.shuffle!,
      uncalibrated_artifacts_num,
      0
    )
  end

  #ADDED :- Helper method to handle standard review mapping without calibrated artifacts
  # @param [Integer] assignment_id - The ID of the assignment.
  # @param [Participant[]] participants - List of participants who can review.
  # @param [Team[]] teams - List of all teams for the assignment.
  # @param [Integer] student_review_num - Number of reviews per student.
  # @param [Integer] submission_review_num - Number of reviewers per team.
  # @param [Boolean] exclude_teams - Whether to exclude teams without submissions.
  # @return [void] - Performs standard review mapping or sets flash error messages for invalid inputs.
  def handle_standard_review_mapping(assignment_id, participants, teams, student_review_num, submission_review_num, exclude_teams)
    # Check for exit paths first
    if student_review_num.zero? && submission_review_num.zero?
      flash[:error] = 'Please choose either the number of reviews per student or the number of reviewers per team (student).'
    elsif !student_review_num.zero? && !submission_review_num.zero?
      flash[:error] = 'Please choose either the number of reviews per student or the number of reviewers per team (student), not both.'
    elsif student_review_num >= teams.size
      # Exception detection: If instructor want to assign too many reviews done
      # by each student, there will be an error msg.
      flash[:error] = 'You cannot set the number of reviews done ' \
                       'by each student to be greater than or equal to total number of teams ' \
                       '[or "participants" if it is an individual assignment].'
    else
      # REVIEW: mapping strategy
      automatic_review_mapping_strategy(assignment_id, participants, teams, student_review_num, submission_review_num, exclude_teams)
    end
  end

  def automatic_review_mapping_strategy(assignment_id,
                                        participants, teams, student_review_num = 0,
                                        submission_review_num = 0, exclude_teams = false)
    participants_hash = {}
    participants.each { |participant| participants_hash[participant.id] = 0 }
    #if exclude_teams_without_submission is true check if team has submission if not discard
    # Filter teams based on the conditions only if exclude_teams is true
    filtered_teams = exclude_teams ? teams.reject { |team| team[:submitted_hyperlinks].nil? && team[:directory_num].nil? } : teams
    # calculate reviewers for each team
    if !student_review_num.zero? && submission_review_num.zero?
      review_strategy = ReviewMappingHelper::StudentReviewStrategy.new(participants, filtered_teams, student_review_num)
    elsif student_review_num.zero? && !submission_review_num.zero?
      review_strategy = ReviewMappingHelper::TeamReviewStrategy.new(participants, filtered_teams, submission_review_num)
    end

    peer_review_strategy(assignment_id, review_strategy, participants_hash)

    # after assigning peer reviews for each team,
    # if there are still some peer reviewers not obtain enough peer review,
    # just assign them to valid teams
    assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
  end

  # This is for staggered deadline assignment
  def automatic_review_mapping_staggered
    assignment = find_assignment(params[:id])
    message = assignment.assign_reviewers_staggered(params[:assignment][:num_reviews], params[:assignment][:num_metareviews])
    flash[:note] = message
    redirect_to action: 'list_mappings', id: assignment.id
  end

  def save_grade_and_comment_for_reviewer
    review_grade = ReviewGrade.find_or_create_by(participant_id: params[:review_grade][:participant_id])
    review_grade.attributes = review_mapping_params
    review_grade.review_graded_at = Time.now
    review_grade.reviewer_id = session[:user].id
    begin
      review_grade.save!
      flash[:success] = 'Grade and comment for reviewer successfully saved.'
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    respond_to do |format|
      format.js { render action: 'save_grade_and_comment_for_reviewer.js.erb', layout: false }
      format.html { redirect_to controller: 'reports', action: 'response_report', id: params[:review_grade][:assignment_id] }
    end
  end

  # E1600
  # Start self review if not started yet - Creates a self-review mapping when user requests a self-review
  def start_self_review
    user_id = params[:reviewer_userid]
    assignment = find_assignment(params[:assignment_id])
    team = Team.find_team_for_assignment_and_user(assignment.id, user_id).first
    begin
      # ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      if SelfReviewResponseMap.where(reviewee_id: team.id, reviewer_id: params[:reviewer_id]).first.nil?
        SelfReviewResponseMap.create(reviewee_id: team.id,
                                     reviewer_id: params[:reviewer_id],
                                     reviewed_object_id: assignment.id)
      else
        raise 'Self review already assigned!'
      end
      redirect_to controller: 'submitted_content', action: 'edit', id: params[:reviewer_id]
    rescue StandardError => e
      redirect_to controller: 'submitted_content', action: 'edit', id: params[:reviewer_id], msg: e.message
    end
  end

  private

  #ADDED : Checks if there are sufficient number of reviews created for the assignment compared to the reviews needed.
  # If the number of reviews created is less than the required, then return true.
  # @param [Integer] assignment_id - The ID of the assignment.
  # @param [Object] review_strategy - The review strategy object containing the number of reviews needed.
  # @return [Boolean] - Returns true if the number of reviews created is less than the required number; false otherwise.
  def check_insufficient_reviews(assignment_id, review_strategy)
    num_reviews_created = ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 0)
                        .where('created_at > :time',
                               time: @@time_create_last_review_mapping_record).size
    if num_reviews_created < review_strategy.reviews_needed
      true
    end
  end



  #EDITED: if_condition_1 and if_condition_2 variable names changed to no_min_assigned_reviews, has_one_participant_with_self_review, is_insufficient_reviews_for_participant and has_participant_not_been_selected
  # @param [Integer] assignment_id - The ID of the assignment.
  # @param [Object] review_strategy - The strategy object that defines reviews_per_team, reviews_per_student, teams, and participants.
  # @param [Hash] participants_hash - A hash mapping participant IDs to the number of reviews already assigned to them.
  # @return [void]
  def peer_review_strategy(assignment_id, review_strategy, participants_hash)
    teams = review_strategy.teams
    participants = review_strategy.participants
    num_participants = participants.size

    teams.each_with_index do |team, iterator|
      selected_participants = []
      if !team.equal? teams.last
        # need to even out the # of reviews for teams
        while selected_participants.size < review_strategy.reviews_per_team
          # if all outstanding participants are already in selected_participants, just break the loop.
          break if selected_participants.size == participants.size - count_active_team_participants(team.id, assignment_id)

          # generate random number
          if iterator.zero?
            rand_num = rand(0..num_participants - 1)
          else
            rand_num = select_random_reviewer_index(participants, participants_hash, team.id, num_participants)
          end
          # prohibit one student to review his/her own artifact
          next if is_self_review?(team.id, participants[rand_num].user_id)

          is_insufficient_reviews_for_participant = (participants_hash[participants[rand_num].id] < review_strategy.reviews_per_student)
          has_participant_not_been_selected = (!selected_participants.include? participants[rand_num].id)
          if is_insufficient_reviews_for_participant && has_participant_not_been_selected
            # selected_participants cannot include duplicate num
            selected_participants << participants[rand_num].id
            participants_hash[participants[rand_num].id] += 1
          end
          # remove students who have already been assigned enough num of reviews out of participants array
          participants.each do |participant|
            if participants_hash[participant.id] == review_strategy.reviews_per_student
              participants.delete_at(rand_num)
              num_participants -= 1
            end
          end
        end
      else
        # REVIEW: num for last team can be different from other teams.
        # prohibit one student to review his/her own artifact and selected_participants cannot include duplicate num
        participants.each do |participant|
          # avoid last team receives too many peer reviews
          if !is_self_review?(team.id, participant.user_id) && (selected_participants.size < review_strategy.reviews_per_team)
            selected_participants << participant.id
            participants_hash[participant.id] += 1
          end
        end
      end

      begin
        selected_participants.each { |index| ReviewResponseMap.where(reviewee_id: team.id, reviewer_id: index, reviewed_object_id: assignment_id).first_or_create }
      rescue StandardError
        flash[:error] = 'Automatic assignment of reviewer failed.'
      end
    end
  end

  def review_mapping_params
    params
      .require(:review_grade)
      .permit(:grade_for_reviewer, :comment_for_reviewer, :review_graded_at)
  end
end