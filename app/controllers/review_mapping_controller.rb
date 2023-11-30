class ReviewMappingController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name
  helper :submitted_content

  @@time_create_last_review_mapping_record = nil

  # Verify which actions are allowed based on the user type.
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

  # Map the review from an individual/team to a team's assignment.
  def add_calibration
    participant = begin
                    AssignmentParticipant.where(parent_id: params[:id], user_id: session[:user].id).first
                  rescue StandardError
                    nil
                  end
    if participant.nil?
      participant = AssignmentParticipant.create(parent_id: params[:id], user_id: session[:user].id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
    end
    map = begin
            ReviewResponseMap.where(reviewed_object_id: params[:id], reviewer_id: participant.get_reviewer.id, reviewee_id: params[:team_id], calibrate_to: true).first
          rescue StandardError
            nil
          end
    map = ReviewResponseMap.create(reviewed_object_id: params[:id], reviewer_id: participant.get_reviewer.id, reviewee_id: params[:team_id], calibrate_to: true) if map.nil?
    redirect_to controller: 'response', action: 'new', id: map.id, assignment_id: params[:id], return: 'assignment_edit'
  end

  # Retrieves the AssignmentTeam object based on the provided contributor ID and sets it in the session.
  # This method is typically used to select a specific contributor (team) for review assignments or other actions.
  def select_reviewer
    @contributor = AssignmentTeam.find(params[:contributor_id])
    session[:contributor] = @contributor
  end

  # Find the meta_reviewer by ID
  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])
  end

  # Add reviewer to an assignment from the existing participants
  def add_reviewer
    assignment = Assignment.find(params[:id])
    topic_id = params[:topic_id] # An assignment can have several topics
    # IF USER NOT FOUND ------> CRAASH!
    user_id = User.where(name: params[:user][:name]).first.id
    # If instructor want to assign one student to review his/her own artifact,
    # it should be counted as "self-review" and we need to make /app/views/submitted_content/_selfreview.html.erb work.
    if TeamsUser.exists?(team_id: params[:contributor_id], user_id: user_id)
      flash[:error] = 'You cannot assign this student to review his/her own artifact.'
    else
      # Team lazy initialization
      SignUpSheet.signup_team(assignment.id, user_id, topic_id)
      msg = ''
      begin
        user = User.from_params(params)
        # contributor_id is team_id
        regurl = url_for id: assignment.id,
                         user_id: user.id,
                         contributor_id: params[:contributor_id]
        # Get the assignment's participant corresponding to the user
        reviewer = get_reviewer(user, assignment, regurl)
        # ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        if ReviewResponseMap.where(reviewee_id: params[:contributor_id], reviewer_id: reviewer.id).first.nil?
          ReviewResponseMap.create(reviewee_id: params[:contributor_id], reviewer_id: reviewer.id, reviewed_object_id: assignment.id)
        else
          raise 'The reviewer, "' + reviewer.name + '", is already assigned to this contributor.'
        end
      rescue StandardError => e
        msg = e.message
      end
    end
    redirect_to action: 'list_mappings', id: assignment.id, msg: msg
  end

  # This method is used for assigning submissions to students for peer review.
  # This method is different from 'assignment_reviewer_automatically', which is used for instructor assigning reviewers in instructor-selected assignment.
  def assign_reviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    participant = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id: assignment.id).first
    reviewer = participant.get_reviewer
    if params[:i_dont_care].nil? && params[:topic_id].nil? && assignment.topics? && assignment.can_choose_topic_to_review?
      flash[:error] = 'No topic is selected.  Please go back and select a topic.'
    else
      if review_allowed?(assignment, reviewer)
        if check_outstanding_reviews?(assignment, reviewer)
          assign_reviewer(assignment, reviewer, params)
        else
          flash[:error] = 'You cannot do more reviews when you have ' + Assignment.max_outstanding_reviews + 'reviews to do'
        end
      else
        flash[:error] = 'You cannot do more than ' + assignment.num_reviews_allowed.to_s + ' reviews based on assignment policy'
      end
    end
    redirect_to controller: 'student_review', action: 'list', id: participant.id
  end

  # This method checks if the user is allowed to do any more reviews as per the assignment policy.
  # If the number of reviews are less than the allowed reviews for a user, then they are allowed to request for an additional review.
  # Can be made private?
  def review_allowed?(assignment, reviewer)
    @review_mappings = ReviewResponseMap.where(reviewer_id: reviewer.id, reviewed_object_id: assignment.id)
    assignment.num_reviews_allowed > @review_mappings.size
  end

  # This method checks if the user that is requesting a review has any outstanding reviews
  # If a user has more than 2 outstanding reviews, he is not allowed to ask for more reviews.
  # Can be made private?
  def check_outstanding_reviews?(assignment, reviewer)
    @review_mappings = ReviewResponseMap.where(reviewer_id: reviewer.id, reviewed_object_id: assignment.id)
    @num_reviews_total = @review_mappings.size
    if @num_reviews_total.zero?
      true
    else
      @num_reviews_completed = 0
      @review_mappings.each do |map|
        @num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
      end
      @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
      # if all reviews done => no outstanding reviews
      @num_reviews_in_progress > 0 && @num_reviews_in_progress < Assignment.max_outstanding_reviews
    end
  end

  # decide the kind of assignment to choose the reviewer assignment logic
  def assign_reviewer(assignment, reviewer, params)
    if assignment.topics?
      assign_reviewer_with_topics(assignment, reviewer, params)
    else
      assign_reviewer_without_topic(assignment, reviewer)
    end
  end

  # assign reviewer for assignments with topics
  def assign_reviewer_with_topics(assignment, reviewer, params)
    topic = if params[:topic_id]
              SignUpTopic.find(params[:topic_id])
            else
              begin
                assignment.candidate_topics_to_review(reviewer).to_a.sample
              rescue StandardError
                nil
              end
            end
    if topic.nil?
      flash[:error] = 'No topics are available to review at this time. Please try later.'
    else
      assignment.assign_reviewer_dynamically(reviewer, topic)
    end
  end

  # assign reviewer for assignments without topics
  def assign_reviewer_without_topic(assignment, reviewer)
    assignment_teams = assignment.candidate_assignment_teams_to_review(reviewer)
    assignment_team = begin
                        assignment_teams.to_a.sample
                      rescue StandardError
                        nil
                      end
    if assignment_team.nil?
      flash[:error] = 'No artifacts are available to review at this time. Please try later.'
    else
      assignment.assign_reviewer_dynamically_no_topic(reviewer, assignment_team)
    end
  end

  # Assigns the quiz dynamically to the participant
  def assign_quiz_dynamically
    begin
      assignment = Assignment.find(params[:assignment_id])
      reviewer = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id: assignment.id).first
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

  # Assign metareviewer to the assignment submitted by a participant
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

  # Assign metareviewer dynamically to an assignment
  def assign_metareviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    metareviewer = AssignmentParticipant.where(user_id: params[:metareviewer_id], parent_id: assignment.id).first
    # this will provide a flash warning instead of page crash when there are no review to Meta review.
    begin
      assignment.assign_metareviewer_dynamically(metareviewer)
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to controller: 'student_review', action: 'list', id: metareviewer.id
  end

  # Returns the reviewer of the assignment
  def get_reviewer(user, assignment, reg_url)
    reviewer = AssignmentParticipant.where(user_id: user.id, parent_id: assignment.id).first
    raise "\"#{user.name}\" is not a participant in the assignment. Please <a href='#{reg_url}'>register</a> this user to continue." if reviewer.nil?
    reviewer.get_reviewer
  rescue StandardError => e
    flash[:error] = e.message
  end

  # Delete all outstanding reviews which have not been started by the reviewer
  def delete_outstanding_reviewers
    assignment = Assignment.find(params[:id])
    team = AssignmentTeam.find(params[:contributor_id])
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

  # Deletes all metareview mappings for a given response map.
  def delete_all_metareviewers
    mapping = ResponseMap.find(params[:id])
    meta_review_mappings = MetareviewResponseMap.where(reviewed_object_id: mapping.map_id)
    num_unsuccessful_deletes = 0
    meta_review_mappings.each do |meta_review_mapping|
      begin
        meta_review_mapping.delete(ActiveModel::Type::Boolean.new.cast(params[:force]))
      rescue StandardError
        num_unsuccessful_deletes += 1
      end
    end
    # Handles confirmation if metareviews exist.
    if num_unsuccessful_deletes > 0
      url_yes = url_for action: 'delete_all_metareviewers', id: mapping.map_id, force: 1
      url_no = url_for action: 'delete_all_metareviewers', id: mapping.map_id
      flash[:error] = "A delete action failed:<br/>#{num_unsuccessful_deletes} metareviews exist for these mappings. " \
                      'Delete these mappings anyway?' \
                      "&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><br/>"
    else
      flash[:note] = 'All metareview mappings for contributor "' + mapping.reviewee.name + '" and reviewer "' + mapping.reviewer.name + '" have been deleted.'
    end
    redirect_to action: 'list_mappings', id: mapping.assignment.id
  end

  # Unsubmit reviews using AJAX
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

  # If a valid ReviewResponseMap is found and there is no associated response,
  # it deletes the mapping. If a response exists, indicating the review has already been done,
  # it prevents the deletion and provides appropriate feedback to the user.
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

  # Handles the deletion of a MetareviewResponseMap object based on the provided ID.
  # It first finds the MetareviewResponseMap object, retrieves the associated assignment ID,
  # sets a note flash message indicating the deletion, attempts to delete the mapping,
  # and handles any exceptions that might occur during the deletion process.
  # Finally, it redirects the user to the list of metareview mappings for the same assignment.
  def delete_metareviewer
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    flash[:note] = 'The metareview mapping for ' + mapping.reviewee.name + ' and ' + mapping.reviewer.name + ' has been deleted.'
    begin
      mapping.delete
    rescue StandardError
      flash[:error] = 'A delete action failed:<br/>' + $ERROR_INFO.to_s + "<a href='/review_mapping/delete_metareview/" + mapping.map_id.to_s + "'>Delete this mapping anyway>?"
    end
    redirect_to action: 'list_mappings', id: assignment_id
  end

  # Deletes a MetareviewResponseMap object based on the provided ID.
  # It deletes the specified metareview mapping and redirects the user to the list of mappings associated with the same assignment.
  def delete_metareview
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    mapping.delete
    redirect_to action: 'list_mappings', id: assignment_id
  end

  # Lists all the mappings (AssignmentTeams) associated with a specific assignment.
  # It sets an error flash message if provided via params and retrieves the assignment and
  # its associated teams for display.
  def list_mappings
    if params[:id] == "0"
      flash[:error] = "Assignment needs to be created in order to assign reviewers!"
      redirect_to "/assignments/new?private=1"
      return
    end
    flash[:error] = params[:msg] if params[:msg]
    @assignment = Assignment.find(params[:id])
    @items = AssignmentTeam.where(parent_id: @assignment.id)
    @items.sort_by(&:name)
  end

  # Assign reviews to submissions based on automatic_review_mapping_strategy
  def automatic_review_mapping
    assignment_id = params[:id].to_i
    participants = AssignmentParticipant.where(parent_id: assignment_id).to_a.select(&:can_review).shuffle!
    teams = AssignmentTeam.where(parent_id: assignment_id).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size])
    student_review_num = params[:num_reviews_per_student].to_i
    submission_review_num = params[:num_reviews_per_submission].to_i
    calibrated_artifacts_num = params[:num_calibrated_artifacts].to_i
    uncalibrated_artifacts_num = params[:num_uncalibrated_artifacts].to_i
    # Create teams if its an individual assignment
    if teams.empty? && max_team_size == 1
      participants.each do |participant|
        user = participant.user
        next if TeamsUser.team_id(assignment_id, user.id)
        team = AssignmentTeam.create_team_and_node(assignment_id)
        ApplicationController.helpers.create_team_users(user, team.id)
        teams << team
      end
    end
    if calibrated_artifacts_num.zero? && uncalibrated_artifacts_num.zero?
      handle_review_assignment(student_review_num, submission_review_num, teams)
    else
      teams_with_calibrated_artifacts, teams_with_uncalibrated_artifacts = divide_teams(assignment_id, teams)
      assign_reviews_to_calibrated_artifacts(assignment_id, teams_with_calibrated_artifacts, calibrated_artifacts_num)
      assign_reviews_to_uncalibrated_artifacts(assignment_id, participants, teams_with_uncalibrated_artifacts, uncalibrated_artifacts_num)
    end
    redirect_to action: 'list_mappings', id: assignment_id
  end

  # Implements an automatic review mapping strategy for an assignment based on the provided parameters.
  # This method calculates and assigns reviewers for each team, utilizing different strategies for student and submission reviews.
  # After assigning peer reviews for each team, it assigns any remaining peer reviewers to valid teams.
  def automatic_review_mapping_strategy(assignment_id,
                                        participants, teams, student_review_num = 0,
                                        submission_review_num = 0)
    participants_hash = {}
    participants.each { |participant| participants_hash[participant.id] = 0 }
    # calculate reviewers for each team
    if !student_review_num.zero? && submission_review_num.zero?
      review_strategy = ReviewMappingHelper::StudentReviewStrategy.new(participants, teams, student_review_num)
    elsif student_review_num.zero? && !submission_review_num.zero?
      review_strategy = ReviewMappingHelper::TeamReviewStrategy.new(participants, teams, submission_review_num)
    end

    peer_review_strategy(assignment_id, review_strategy, participants_hash)

    # after assigning peer reviews for each team,
    # if there are still some peer reviewers not obtain enough peer review,
    # just assign them to valid teams
    assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
  end

  # Utilized when an assignment has staggered deadlines
  def automatic_review_mapping_staggered
    assignment = Assignment.find(params[:id])
    message = assignment.assign_reviewers_staggered(params[:assignment][:num_reviews], params[:assignment][:num_metareviews])
    flash[:note] = message
    redirect_to action: 'list_mappings', id: assignment.id
  end

  # Handles the saving of grade and comments provided by a reviewer for a specific review mapping.
  # It retrieves or creates a ReviewGrade object associated with the given participant ID and assigns the grade,
  # comments, reviewer information, and timestamp. It then attempts to save the ReviewGrade object, displaying
  # appropriate flash messages based on the success or failure of the operation.
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

  # Start self review if not started yet - Creates a self-review mapping when user requests a self-review
  def start_self_review
    user_id = params[:reviewer_userid]
    assignment = Assignment.find(params[:assignment_id])
    team = Team.find_team_for_assignment_and_user(assignment.id, user_id).first
    begin
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

  # Check qualifying conditions to successfully define instructor-defined review strategy.
  def handle_review_assignment(student_review_num, submission_review_num, teams)
    if student_review_num.zero? && submission_review_num.zero?
      flash[:error] = 'Please choose either the number of reviews per student or the number of reviewers per team (student).'
    elsif !student_review_num.zero? && !submission_review_num.zero?
      flash[:error] = 'Please choose either the number of reviews per student or the number of reviewers per team (student), not both.'
    elsif student_review_num >= teams.size
      flash[:error] = 'You cannot set the number of reviews done ' \
        'by each student to be greater than or equal to total number of teams ' \
        '[or "participants" if it is an individual assignment].'
    else
      automatic_review_mapping_strategy(params[:id].to_i, AssignmentParticipant.where(parent_id: params[:id].to_i).select(&:can_review).shuffle, teams, student_review_num, submission_review_num)
    end
  end

  # Divide teams based on calibrated/uncalibrated artifacts.
  def divide_teams(assignment_id, teams)
    teams_with_calibrated_artifacts = ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 1).map { |response_map| AssignmentTeam.find(response_map.reviewee_id) }
    teams_with_uncalibrated_artifacts = teams - teams_with_calibrated_artifacts
    [teams_with_calibrated_artifacts.shuffle, teams_with_uncalibrated_artifacts.shuffle]
  end

  # Assigns peer reviewers to teams with calibrated artifacts for a specific assignment.
  # It utilizes the automatic review mapping strategy, considering calibrated artifacts and the specified number of reviews per artifact.
  def assign_reviews_to_calibrated_artifacts(assignment_id, teams_with_calibrated_artifacts, calibrated_artifacts_num)
    automatic_review_mapping_strategy(assignment_id, AssignmentParticipant.where(parent_id: params[:id].to_i).select(&:can_review).shuffle, teams_with_calibrated_artifacts, calibrated_artifacts_num, 0)
  end

  # Assigns peer reviewers to teams with uncalibrated artifacts for a specific assignment.
  # It utilizes the automatic review mapping strategy, considering calibrated artifacts and the specified number of reviews per artifact.
  def assign_reviews_to_uncalibrated_artifacts(assignment_id, participants, teams_with_uncalibrated_artifacts, uncalibrated_artifacts_num)
    automatic_review_mapping_strategy(assignment_id, participants, teams_with_uncalibrated_artifacts, uncalibrated_artifacts_num, 0)
  end

  # Assigns additional reviewers to teams based on specific review strategy and insufficient review assignments.
  # If there are still peer reviewers who have not received enough assignments after the initial strategy,
  # this method assigns them to valid teams to ensure all participants receive sufficient reviews.

  # ERROR IN THIS FUNCTION - no tests written - can be refactored?
  def assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
    if ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 0)
                        .where('created_at > :time',
                               time: @@time_create_last_review_mapping_record).size < review_strategy.reviews_needed

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
          next if TeamsUser.exists?(team_id: team_id,
                                    user_id: Participant.find(participant_id).user_id)

          participant = AssignmentParticipant.find(participant_id)
          ReviewResponseMap.where(reviewee_id: team_id, reviewer_id: participant.get_reviewer.id,
                                  reviewed_object_id: assignment_id).first_or_create

          teams_hash[team_id] += 1
          teams_hash = teams_hash.sort_by { |_, v| v }.to_h
          break
        end
      end
    end

    # ERROR DESCRIPTION
    # Will work if no participants assigned
    # SOLUTION
    # Configure an error message for the same and have a check
    @@time_create_last_review_mapping_record = ReviewResponseMap
                                               .where(reviewed_object_id: assignment_id)
                                               .last.created_at
  end

  # Implements a peer review assignment strategy for teams based on the provided review strategy and assignment parameters.
  # It distributes reviewers among teams, ensuring each team receives an appropriate number of reviews as per the strategy.
  def peer_review_strategy(assignment_id, review_strategy, participants_hash)
    teams = review_strategy.teams
    participants = review_strategy.participants
    num_participants = participants.size

    teams.each_with_index do |team, iterator|
      selected_participants = []
      if !team.equal? teams.last
        # need to even out the # of reviews for teams
        while selected_participants.size < review_strategy.reviews_per_team
          num_participants_this_team = TeamsUser.where(team_id: team.id).size
          # If there are some submitters or reviewers in this team, they are not treated as normal participants.
          # They should be removed from 'num_participants_this_team'
          TeamsUser.where(team_id: team.id).each do |team_user|
            temp_participant = Participant.where(user_id: team_user.user_id, parent_id: assignment_id).first
            num_participants_this_team -= 1 unless temp_participant.can_review && temp_participant.can_submit
          end
          # if all outstanding participants are already in selected_participants, just break the loop.
          break if selected_participants.size == participants.size - num_participants_this_team

          # generate random number
          rand_num = generate_participant_rand_num(participants, participants_hash, num_participants, iterator)

          # prohibit one student to review his/her own artifact
          next if TeamsUser.exists?(team_id: team.id, user_id: participants[rand_num].user_id)

          # We add the participant assigned with rand_num to the list of selected_participants, selectively
          selected_participants.append(update_selected_participants(participants, participants_hash, review_strategy, rand_num))

          # remove students who have already been assigned enough num of reviews out of participants array
          participants.each do |participant|
            if participants_hash[participant.id] == review_strategy.reviews_per_student
              participants.delete_at(rand_num)
              num_participants -= 1
            end
          end
        end
      else
        # Handle peer review for last team
        selected_participants.append(peer_review_strategy_for_last_team(participants, team, review_strategy, participants_hash))

      end

      begin
        selected_participants.each do |index|
          ReviewResponseMap.where(reviewee_id: team.id, reviewer_id: index, reviewed_object_id: assignment_id).first_or_create
        end
      rescue StandardError
        flash[:error] = 'Automatic assignment of reviewer failed.'
      end
    end
  end

  # Generates random number for a participant for peer reviewing
  def generate_participant_rand_num(participants, participants_hash, num_participants, iterator)
    # generate random number
    if iterator.zero?
      rand(0..num_participants - 1)
    else
      calculate_rand_num(participants_hash, participants, num_participants)
    end
  end

  # calculates rand_num(random number) based on checks
  def calculate_rand_num(participants_hash, participants, num_participants)
    min_value = participants_hash.values.min
    # get the temp array including indices of participants, each participant has minimum review number in hash table.
    participants_with_min_assigned_reviews = []
    participants.each do |participant|
      participants_with_min_assigned_reviews << participants.index(participant) if participants_hash[participant.id] == min_value
    end
    # if participants_with_min_assigned_reviews is blank
    is_participants_with_min_assigned_reviews_empty = participants_with_min_assigned_reviews.empty?
    # or only one element in participants_with_min_assigned_reviews, prohibit one student to review his/her own artifact
    is_one_and_its_own_artifact = ((participants_with_min_assigned_reviews.size == 1) && TeamsUser.exists?(team_id: team.id, user_id: participants[participants_with_min_assigned_reviews[0]].user_id))
    if is_participants_with_min_assigned_reviews_empty || is_one_and_its_own_artifact
      # use original method to get random number
      rand(0..num_participants - 1)
    else
      # rand_num should be the position of this participant in original array
      participants_with_min_assigned_reviews[rand(0..participants_with_min_assigned_reviews.size - 1)]
    end
  end

  # We add the participant assigned with rand_num to the list of selected_participants, based on some pre-conditions
  def update_selected_participants(participants, participants_hash, review_strategy, rand_num)
    selected_participants = []
    # if participants_hash for that particular participant is less than expected reviews per student
    is_less_reviews = (participants_hash[participants[rand_num].id] < review_strategy.reviews_per_student)
    # if selected_participants does not include that particular participant
    is_participant_not_included = (!selected_participants.include? participants[rand_num].id)
    if is_less_reviews && is_participant_not_included
      # selected_participants cannot include duplicate num
      selected_participants << participants[rand_num].id
      participants_hash[participants[rand_num].id] += 1
    end

    selected_participants
  end

  def peer_review_strategy_for_last_team(participants, team, review_strategy, participants_hash)
    # REVIEW: num for last team can be different from other teams.
    # prohibit one student to review his/her own artifact and selected_participants cannot include duplicate num
    selected_participants = []

    participants.each do |participant|
      # avoid last team receives too many peer reviews
      if !TeamsUser.exists?(team_id: team.id, user_id: participant.user_id) && (selected_participants.size < review_strategy.reviews_per_team)
        selected_participants << participant.id
        participants_hash[participant.id] += 1
      end
    end

    selected_participants
  end

  def review_mapping_params
    params
      .require(:review_grade)
      .permit(:grade_for_reviewer, :comment_for_reviewer, :review_graded_at)
  end
end
