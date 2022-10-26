=begin
  Implements: assigning reviewers to projects and reviewers to teams
  Used: for automatic review mapping, peer review, self review and dynamic reviewer assignment.
=end

class ReviewMappingController < ApplicationController
  include AuthorizationHelper

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
    else current_user_has_instructor_privileges?
    end
  end

=begin
  Used: when instructor wants to do an expert peer-review and adds calibration 
  Implements: checking by user_id, if the the instructor is a participant in the assignment.
              If not, he is made a new participant. When the record in the ReviewReponseMap 
              doesn't exist, it creates a new record. The record's id is then passed to the 
              response controller to create a new response. 
=end

  def add_calibration_for_instructor
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

  def select_reviewer
    @contributor = AssignmentTeam.find(params[:contributor_id])
    session[:contributor] = @contributor
  end

  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])
  end

=begin
  Used: to assign an new reviewer (who is not already assigned) to a team
  Implements: checks if a ReviewResponse map exists for that reviewer (user). 
              Raises error if reviewer is already assigned to the team.
  Returns: error_msg
=end
  def assign_unseen_reviewer_to_team(assignment, user_id)
    error_msg = ''
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
      error_msg = e.message
    end
    error_msg
  end

=begin
  Used: to assign a user as a reviewer to a team
  Implements: checks if a user belongs to one's own team, in which case they cannot self-review.
               Else, redirects to the SignUpSheet and assigns an unseen reviewer to a team
=end
  def add_reviewer_to_team
    assignment = Assignment.find(params[:id])
    topic_id = params[:topic_id]
    user_id = User.where(name: params[:user][:name]).first.id
    # If instructor want to assign one student to review his/her own artifact,
    # it should be counted as "self-review" and we need to make /app/views/submitted_content/_selfreview.html.erb work.
    if TeamsUser.exists?(team_id: params[:contributor_id], user_id: user_id)
      flash[:error] = 'You cannot assign this student to review his/her own artifact.'
    else
      # Team lazy initialization
      SignUpSheet.signup_team(assignment.id, user_id, topic_id)
      msg = assign_unseen_reviewer_to_team(assignment, user_id)
    end
    redirect_to action: 'list_mappings', id: assignment.id, msg: msg
  end

=begin
  Used: to assign reviewer when topic is known
  Implements: finds topics to be reviewed by reviewer, raises error if no topics are present
=end
  def assign_reviewer_with_topic(assignment,reviewer)
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

=begin
  Used: to assign reviewer to assignment_team's submission, when topic is not known
  Implements: finds an assignment_team whose assignment has no previous reviewer
=end
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

  # 7/12/2015 -zhewei
  # This method is used for assign submissions to students for peer review.
  # This method is different from 'assignment_reviewer_automatically', which is in 'review_mapping_controller'
  # and is used for instructor assigning reviewers in instructor-selected assignment.
  def assign_reviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    participant = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id: assignment.id).first
    reviewer = participant.get_reviewer
    if params[:i_dont_care].nil? && params[:topic_id].nil? && assignment.topics? && assignment.can_choose_topic_to_review?
      flash[:error] = 'No topic is selected.  Please go back and select a topic.'
    else
      if review_allowed?(assignment, reviewer)
        if check_outstanding_reviews?(assignment, reviewer)
          # begin
          if assignment.topics? # assignment with topics
            assign_reviewer_with_topic(assignment,reviewer)
          else # assignment without topic -Yang
            assign_reviewer_without_topic(assignment, reviewer)
          end
        else
          flash[:error] = 'You cannot do more reviews when you have ' + Assignment.max_outstanding_reviews + 'reviews to do'
        end
      else
        flash[:error] = 'You cannot do more than ' + assignment.num_reviews_allowed.to_s + ' reviews based on assignment policy'
      end
      # rescue Exception => e
      #   flash[:error] = (e.nil?) ? $! : e
      # end
    end
    redirect_to controller: 'student_review', action: 'list', id: participant.id
  end

  # This method checks if the user is allowed to do any more reviews.
  # First we find the number of reviews done by that reviewer for that assignment and we compare it with assignment policy
  # if number of reviews are less than allowed than a user is allowed to request.
  def review_allowed?(assignment, reviewer)
    @review_mappings = ReviewResponseMap.where(reviewer_id: reviewer.id, reviewed_object_id: assignment.id)
    assignment.num_reviews_allowed > @review_mappings.size
  end

  # This method checks if the user that is requesting a review has any outstanding reviews, if a user has more than 2
  # outstanding reviews, he is not allowed to ask for more reviews.
  # First we find the reviews done by that student, if he hasn't done any review till now, true is returned
  # else we compute total reviews completed by adding each response
  # we then check of the reviews in progress are less than assignment's policy
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
      @num_reviews_in_progress < Assignment.max_outstanding_reviews
    end
  end

  # assigns the quiz dynamically to the participant
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

=begin
  Used: to create a metareviewer to a reviewer.
  Implements: finding a user from the params and checking if a reviewer is already assigned
              as a metareviewer. If so, then it throws a flash message, else it creates
              a meta reviewer.
=end
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

=begin
  Used: to assign a metareviwer dynamically.
  Implements: Finds the assignment and meatreviewer and assigns the metareviwer to the 
              assignment dynamically.
=end
  def assign_metareviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    metareviewer = AssignmentParticipant.where(user_id: params[:metareviewer_id], parent_id: assignment.id).first
    # this will prvide a flash warning instead of page crash when there are no review to Meta review.
    begin
      assignment.assign_metareviewer_dynamically(metareviewer)
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to controller: 'student_review', action: 'list', id: metareviewer.id
  end

=begin
  Used: to retrieve reviewer from AssignmentParticipant
  Implements: Checking if reviewer exists and if not, an error is thrown asking the user
              to register the user.
=end
  def get_reviewer(user, assignment, reg_url)
    reviewer = AssignmentParticipant.where(user_id: user.id, parent_id: assignment.id).first
    raise "\"#{user.name}\" is not a participant in the assignment. Please <a href='#{reg_url}'>register</a> this user to continue." if reviewer.nil?

    reviewer.get_reviewer
  rescue StandardError => e
    flash[:error] = e.message
  end

=begin
  Used: to remove reviewers not working on any reviews.
  Implements: deletes reviewers from ReviewResponseMap and after the deletions, if values
              still exist in ReviewResponseMap, then the method throws an alert.
=end
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

=begin
  Used: to delete all meta reviewers and to keep track of unsuccessful deletions.
  Implements: checks the number of unsuccessful deletions and if greater than 0, it throws
              an alert.
=end
  def delete_all_metareviewers
    mapping = ResponseMap.find(params[:id])
    meta_reviwer_mappings = MetareviewResponseMap.where(reviewed_object_id: mapping.map_id)
    num_unsuccessful_deletes = 0
    meta_reviwer_mappings.each do |meta_reviwer_mapping|
      begin
        meta_reviwer_mapping.delete(ActiveModel::Type::Boolean.new.cast(params[:force]))
      rescue StandardError
        num_unsuccessful_deletes += 1
      end
    end

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

=begin
  Used: to delete the review mappings from review response maps
  Implements: deleting the review mapping if it exists but if review is already done, 
  the method shows an error that the review annot be deleted.
=end
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

=begin
  Used: to delete the meta review mapping from meta review response map
  Implements: finding the mapping using id, then deletes the mapping from the map. 
              Upon deletion failure, method allows forceful deletion by the user
=end
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

  def delete_metareview
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    # metareview = mapping.response
    # metareview.delete
    mapping.delete
    redirect_to action: 'list_mappings', id: assignment_id
  end

  def list_mappings
    flash[:error] = params[:msg] if params[:msg]
    @assignment = Assignment.find(params[:id])
    # ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @items = AssignmentTeam.where(parent_id: @assignment.id)
    @items.sort_by(&:name)
  end

=begin
  Used: to create a team and assign a participant
  Implements: creates a new team and assigns for each participant by iterating through participants 
=end
  def create_individual_team(participants, assignment_id, teams)
    participants.each do |participant|
      user = participant.user
      next if TeamsUser.team_id(assignment_id, user.id)

      team = AssignmentTeam.create_team_and_node(assignment_id)
      ApplicationController.helpers.create_team_users(user, team.id)
      teams << team
    end
  end

=begin
  Used: to ensure that instructor does not assign too many reviews to a student
  Implements: checks if num of reviews to be done by the student is greater than the total number of teams 
              and throws an error if so, else it calls a mapping strategy method
=end
  def strategy_mapping_without_artifacts(num_student_reviews, num_submission_reviews, teams,assignment_id, participants)
    # check for exit paths first
    if num_student_reviews.zero? && num_submission_reviews.zero?
      flash[:error] = 'Please choose either the number of reviews per student or the number of reviewers per team (student).'
    elsif !num_student_reviews.zero? && !num_submission_reviews.zero?
      flash[:error] = 'Please choose either the number of reviews per student or the number of reviewers per team (student), not both.'
    elsif num_student_reviews >= teams.size
      # Exception detection: If instructor want to assign too many reviews done
      # by each student, there will be an error msg.
      flash[:error] = 'You cannot set the number of reviews done ' \
                       'by each student to be greater than or equal to total number of teams ' \
                       '[or "participants" if it is an individual assignment].'
    else
      # REVIEW: mapping strategy
      automatic_review_mapping_strategy(assignment_id, participants, teams, num_student_reviews, num_submission_reviews)
    end
  end

=begin
  Used: to perform mapping strategy on calibrated artifacts and uncalibrated artifacts
  Implements: identifies the teams with calibrated artifacts and uncalibrated artifacts and performs mapping
=end
  def strategy_mapping_with_artifacts(assignment_id, teams, participants, num_calibrated_artifacts, num_uncalibrated_artifacts)
    teams_with_calibrated_artifacts = []
      ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 1).each do |response_map|
        teams_with_calibrated_artifacts << AssignmentTeam.find(response_map.reviewee_id)
      end
      teams_with_uncalibrated_artifacts = teams - teams_with_calibrated_artifacts
      # REVIEW: mapping strategy
      automatic_review_mapping_strategy(assignment_id, participants, teams_with_calibrated_artifacts.shuffle!, num_calibrated_artifacts, 0)
      # REVIEW: mapping strategy
      # since after first mapping, participants (delete_at) will be nil
      participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
      automatic_review_mapping_strategy(assignment_id, participants, teams_with_uncalibrated_artifacts.shuffle!, num_uncalibrated_artifacts, 0)
  end

=begin
  Used: to perform automatic review mapping
  Implements: checks if the assignment is an individual assignment, if so, it creates a team. 
              Depending on the num of calibrated and uncalibrated artifacts, respective mapping strategies are performed. 
=end
  def automatic_review_mapping
    assignment_id = params[:id].to_i
    participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
    teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
    # Create teams if its an individual assignment.
    if teams.empty? && max_team_size == 1
      create_individual_team(participants, assignment_id, teams)
    end
    num_student_reviews = params[:num_reviews_per_student].to_i
    num_submission_reviews = params[:num_reviews_per_submission].to_i
    num_calibrated_artifacts = params[:num_calibrated_artifacts].to_i
    num_uncalibrated_artifacts = params[:num_uncalibrated_artifacts].to_i

    if num_calibrated_artifacts.zero? && num_uncalibrated_artifacts.zero?
      strategy_mapping_without_artifacts(num_student_reviews, num_submission_reviews, teams,assignment_id, participants)

    else
      strategy_mapping_with_artifacts(assignment_id, teams, participants, num_calibrated_artifacts, num_uncalibrated_artifacts)
    end
    redirect_to action: 'list_mappings', id: assignment_id
  end

=begin
  Used: to perform peer review strategy and assign reviewers for a team
  Implements: calculates reviewers for each team and calls peer review strategy if review strategy exists.
              If there are some peer reviewers without enough peer reviews, assign them to valid teams
=end
  def automatic_review_mapping_strategy(assignment_id,
                                        participants, teams, num_students_review = 0,
                                        num_submission_review = 0)
    participants_hash = {}
    participants.each { |participant| participants_hash[participant.id] = 0 }
    # calculate reviewers for each team
    if !num_students_review.zero? && num_submission_review.zero?
      review_strategy = ReviewMappingHelper::StudentReviewStrategy.new(participants, teams, num_students_review)
    elsif num_students_review.zero? && !num_submission_review.zero?
      review_strategy = ReviewMappingHelper::TeamReviewStrategy.new(participants, teams, num_submission_review)
    end

    if review_strategy
      peer_review_strategy(assignment_id, review_strategy, participants_hash)

      # after assigning peer reviews for each team,
      # if there are still some peer reviewers not obtain enough peer review,
      # just assign them to valid teams
      assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
    end
  end

  # This is for staggered deadline assignment
  def automatic_review_mapping_staggered
    assignment = Assignment.find(params[:id])
    message = assignment.assign_reviewers_staggered(params[:assignment][:num_reviews], params[:assignment][:num_metareviews])
    flash[:note] = message
    redirect_to action: 'list_mappings', id: assignment.id
  end

=begin
  Used: save grade and comments for the reviewer
  Implements: checks if a review grade exists for a participant, if not, creates a review grade record 
              and assigns grade and other values for the reviewer. Throws error message if review grade is not updated successfully
=end
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
      format.html { redirect_to controller: 'reports', action: 'response_report', id: params[:assignment_id] }
    end
  end

=begin 
  E1600
  Used: to start a self-review
  Implements: checking if a self-review has started and if not, creates a self review mapping when user
              requests a self-review
=end 
  def start_self_review
    user_id = params[:reviewer_userid]
    assignment = Assignment.find(params[:assignment_id])
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

=begin
  Used: to generate sorted teams hash
  Implements: generates an unsorted hash then sorts it
  Returns: sorted teams hash
=end
  def generate_sorted_teams_hash(assignment_id)
    unsorted_teams_hash = {}

    ReviewResponseMap.where(reviewed_object_id: assignment_id,
                            calibrate_to: 0).each do |response_map|
      if unsorted_teams_hash.key? response_map.reviewee_id
        unsorted_teams_hash[response_map.reviewee_id] += 1
      else
        unsorted_teams_hash[response_map.reviewee_id] = 1
      end
    end
    unsorted_teams_hash.sort_by { |_, v| v }.to_h
  end

=begin
  Used: to increment value in teams hash
  Implements: finds participants with insufficient num of reviews and increments the team hash accordingly
=end
  def increment_teams_hash(participants_with_insufficient_review_num, teams_hash, assignment_id)
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

=begin
  Used: assigns reviewers for a team
  Implemets: finds participants who have insufficient reviews and assigns reviewers to them
=end
  def assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
    if ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 0)
                        .where('created_at > :time',
                               time: @@time_create_last_review_mapping_record).size < review_strategy.reviews_needed

      participants_with_insufficient_review_num = []
      participants_hash.each do |participant_id, review_num|
        participants_with_insufficient_review_num << participant_id if review_num < review_strategy.reviews_per_student
      end
      
      sorted_teams_hash = generate_sorted_teams_hash(assignment_id)
      increment_teams_hash(participants_with_insufficient_review_num, sorted_teams_hash, assignment_id)
      
    end
    @@time_create_last_review_mapping_record = ReviewResponseMap
                                               .where(reviewed_object_id: assignment_id)
                                               .last.created_at
  end

=begin
  Used: to generate a random participant index
  Implements: checks for participants with min assigned reviews and if it is blank or if there is only one 
              element in participants_with_min_assigned_reviews, it does not allow a user to review their artifact.
              It instead generates an index of a random participant. 
=end
  def generate_random_participant_index(iterator, participants_hash, num_participants)
    if iterator.zero?
      random_participant_index = rand(0..num_participants - 1)
    else
      min_value = participants_hash.values.min
      # get the temp array including indices of participants, each participant has minimum review number in hash table.
      participants_with_min_assigned_reviews = []
      participants.each do |participant|
        participants_with_min_assigned_reviews << participants.index(participant) if participants_hash[participant.id] == min_value
      end
      # if participants_with_min_assigned_reviews is blank
      check_min_assigned_reviews = participants_with_min_assigned_reviews.empty?
      # or only one element in participants_with_min_assigned_reviews, prohibit one student to review his/her own artifact
      check_participants_with_min_reviews = ((participants_with_min_assigned_reviews.size == 1) && TeamsUser.exists?(team_id: team.id, user_id: participants[participants_with_min_assigned_reviews[0]].user_id))
      random_participant_index = if check_min_review_participants || check_participants_with_min_reviews
                   # use original method to get random number
                   rand(0..num_participants - 1)
                 else
                   # random_participant_index should be the position of this participant in original array
                   participants_with_min_assigned_reviews[rand(0..participants_with_min_assigned_reviews.size - 1)]
                 end
    end
    random_participant_index
  end

=begin
  Used: to even out the number of reviews among teams for a given assignment id.
  Implements: tracks num of reviews assigned to a participant and uses selected_participants to track particiant
              ids which are selected to review for a particular team. 
=end
  def distribute_reviews_among_teams(team, assignment_id, review_strategy, selected_participants, participants_hash, iterator, num_participants, participants)
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
      random_participant_index = generate_random_participant_index(iterator, participants_hash, num_participants)
      # prohibit one student to review his/her own artifact
      next if TeamsUser.exists?(team_id: team.id, user_id: participants[random_participant_index].user_id)

      check_reviews_per_participant = (participants_hash[participants[random_participant_index].id] < review_strategy.reviews_per_student)
      is_participant_in_selected_participants = (!selected_participants.include? participants[random_participant_index].id)
      if check_reviews_per_participant && is_participant_in_selected_participants
        # selected_participants cannot include duplicate num
        selected_participants << participants[random_participant_index].id
        participants_hash[participants[random_participant_index].id] += 1
      end
      # remove students who have already been assigned enough num of reviews out of participants array
      participants.each do |participant|
        if participants_hash[participant.id] == review_strategy.reviews_per_student
          participants.delete_at(random_participant_index)
          num_participants -= 1
        end
      end
    end
  end

=begin
  Used: to allocate reviews to participants
  Implements: a strategy to allocate reviews using the concept of evenly distributing the reviews to participants
              and not assigning the participant to review their work.
=end
  def peer_review_strategy(assignment_id, review_strategy, participants_hash)
    teams = review_strategy.teams
    participants = review_strategy.participants
    num_participants = participants.size

    teams.each_with_index do |team, iterator|
      selected_participants = []
      if !team.equal? teams.last
        # need to even out the # of reviews for teams
        distribute_reviews_among_teams(team, assignment_id, review_strategy, selected_participants, participants_hash, iterator, num_participants, participants)
      else
        # REVIEW: num for last team can be different from other teams.
        # prohibit one student to review his/her own artifact and selected_participants cannot include duplicate num
        participants.each do |participant|
          # avoid last team receives too many peer reviews
          if !TeamsUser.exists?(team_id: team.id, user_id: participant.user_id) && (selected_participants.size < review_strategy.reviews_per_team)
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
