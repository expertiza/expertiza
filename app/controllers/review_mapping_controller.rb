class ReviewMappingController < ApplicationController
  autocomplete :user, :name
  # use_google_charts
  require 'gchart'
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
    participant = AssignmentParticipant.where(parent_id: params[:id], user_id: session[:user].id).first rescue nil
    if participant.nil?
      participant = AssignmentParticipant.create(parent_id: params[:id], user_id: session[:user].id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
    end
    map = ReviewResponseMap.where(reviewed_object_id: params[:id], reviewer_id: participant.id, reviewee_id: params[:team_id], calibrate_to: true).first rescue nil
    map = ReviewResponseMap.create(reviewed_object_id: params[:id], reviewer_id: participant.id, reviewee_id: params[:team_id], calibrate_to: true) if map.nil?
    redirect_to controller: 'response', action: 'new', id: map.id, assignment_id: params[:id], return: 'assignment_edit'
  end

  def select_reviewer
    @contributor = AssignmentTeam.find(params[:contributor_id])
    session[:contributor] = @contributor
  end

  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])
  end

  def add_reviewer
    assignment = Assignment.find(params[:id])
    topic_id = params[:topic_id]
    if params[:user][:name] == ""
      msg = 'User field cannot be empty'
    else
      user_id = User.where(name: params[:user][:name]).first.id rescue nil
      msg = "Cannot find user '" + params[:user][:name] + "'" unless user_id
    end
    # If instructor want to assign one student to review his/her own artifact,
    # it should be counted as “self-review” and we need to make /app/views/submitted_content/_selfreview.html.erb work.

    participant_temp = Participant.where(user_id: user_id, parent_id: params[:id]).first rescue nil
    # msg = 'User field cannot be empty'

    # Check for user field is empty or not
    if user_id
      if TeamsUser.exists?(team_id: params[:contributor_id], user_id: user_id)
        flash[:error] = "You cannot assign this student to review his/her own artifact."

        # If the user is not allowed to review this assignment
      elsif !participant_temp or !participant_temp.can_review
        flash[:error] = "This user is not authorized to review the assignment."
        msg = 'This user is not authorized to review the assignment.'
      else
        # Team lazy initialization
        SignUpSheet.signup_team(assignment.id, user_id, topic_id)

        begin
          user = User.from_params(params)
          # contributor_id is team_id
          regurl = url_for id: assignment.id,
                           user_id: user.id,
                           contributor_id: params[:contributor_id]

          # Get the assignment's participant corresponding to the user
          reviewer = get_reviewer(user, assignment, regurl)
          # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
          # to treat all assignments as team assignments
          if ReviewResponseMap.where(reviewee_id: params[:contributor_id], reviewer_id: reviewer.id).first.nil?
            ReviewResponseMap.create(reviewee_id: params[:contributor_id], reviewer_id: reviewer.id, reviewed_object_id: assignment.id)
          else
            raise "The reviewer, \"" + reviewer.name + "\", is already assigned to this contributor."
          end
        rescue StandardError => e
          msg = e.message
        end
      end
    end
    redirect_to action: 'list_mappings', id: assignment.id, msg: msg
  end

  # 7/12/2015 -zhewei
  # This method is used for assign submissions to students for peer review.
  # This method is different from 'assignment_reviewer_automatically', which is in 'review_mapping_controller'
  # and is used for instructor assigning reviewers in instructor-selected assignment.
  def assign_reviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    reviewer = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id: assignment.id).first

    if params[:i_dont_care].nil? && params[:topic_id].nil? && assignment.topics? && assignment.can_choose_topic_to_review?
      flash[:error] = "No topic is selected.  Please go back and select a topic."
    else

      # begin
      if assignment.topics? # assignment with topics
        topic = if params[:topic_id]
                  SignUpTopic.find(params[:topic_id])
                else
                  assignment.candidate_topics_to_review(reviewer).to_a.sample rescue nil
                end
        if topic.nil?
          flash[:error] = "No topics are available to review at this time. Please try later."
        else
          assignment.assign_reviewer_dynamically(reviewer, topic)
        end

      else # assignment without topic -Yang
        assignment_teams = assignment.candidate_assignment_teams_to_review(reviewer)
        assignment_team = assignment_teams.to_a.sample rescue nil
        if assignment_team.nil?
          flash[:error] = "No artifacts are available to review at this time. Please try later."
        else
          assignment.assign_reviewer_dynamically_no_topic(reviewer, assignment_team)
        end

      end
    end
    # rescue Exception => e
    #   flash[:error] = (e.nil?) ? $! : e
    # end

    redirect_to controller: 'student_review', action: 'list', id: reviewer.id
  end

  # assigns the quiz dynamically to the participant
  def assign_quiz_dynamically
    begin
      assignment = Assignment.find(params[:assignment_id])
      reviewer = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id: assignment.id).first
      if ResponseMap.where(reviewed_object_id: params[:questionnaire_id], reviewer_id: params[:participant_id]).first
        flash[:error] = "You have already taken that quiz."
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

  def add_metareviewer
    mapping = ResponseMap.find(params[:id])
    msg = ''
    begin
      user = User.from_params(params)

      regurl = url_for action: 'add_user_to_assignment', id: mapping.map_id, user_id: user.id
      reviewer = get_reviewer(user, mapping.assignment, regurl)
      unless MetareviewResponseMap.where(reviewed_object_id: mapping.map_id, reviewer_id: reviewer.id).first.nil?
        raise "The metareviewer \"" + reviewer.user.name + "\" is already assigned to this reviewer."
      end
      MetareviewResponseMap.create(reviewed_object_id: mapping.map_id,
                                   reviewer_id: reviewer.id,
                                   reviewee_id: mapping.reviewer.id)
    rescue StandardError => e
      msg = e.message
    end
    redirect_to action: 'list_mappings', id: mapping.assignment.id, msg: msg
  end

  def assign_metareviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    metareviewer = AssignmentParticipant.where(user_id: params[:metareviewer_id], parent_id: assignment.id).first
    begin
      assignment.assign_metareviewer_dynamically(metareviewer)
    rescue StandardError => e
      flash[:error] = e
    end
    redirect_to controller: 'student_review', action: 'list', id: metareviewer.id
  end

  def get_reviewer(user, assignment, reg_url)
    begin
      reviewer = AssignmentParticipant.where(user_id: user.id, parent_id: assignment.id).first
      raise "\"#{user.name}\" is not a participant in the assignment. Please <a href='#{reg_url}'>register</a> this user to continue." if reviewer.nil?
      reviewer
    rescue StandardError => e
      flash[:error] = e.message
    end
  end

  def delete_outstanding_reviewers
    assignment = Assignment.find(params[:id])
    team = AssignmentTeam.find(params[:contributor_id])
    review_response_maps = team.review_mappings
    num_remain_review_response_maps = review_response_maps.size
    # Iterate through every response and related answers and check whether they are empty or not
    review_response_maps.each do |review_response_map|
      flag = nil
      if review_response_map and Response.exists?(map_id: review_response_map.id)
        Response.where(map_id: review_response_map.id).each do |response|
          break unless flag.nil?
          flag = 1 unless response.additional_comment.empty?
          Answer.where(response_id: response.id).each do |answer|
            if !answer.comments.empty? or (answer.answer != 0 and !answer.answer.nil?)
              flag = 1
            end
            break unless flag.nil?
          end
        end
      end
      if flag.nil?
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

  def delete_all_metareviewers
    mapping = ResponseMap.find(params[:id])
    mmappings = MetareviewResponseMap.where(reviewed_object_id: mapping.map_id)
    num_unsuccessful_deletes = 0
    mmappings.each do |mmapping|
      begin
        mmapping.delete(params[:force])
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
      flash[:note] = "All metareview mappings for contributor \"" + mapping.reviewee.name + "\" and reviewer \"" + mapping.reviewer.name + "\" have been deleted."
    end
    redirect_to action: 'list_mappings', id: mapping.assignment.id
  end

  # E1721: Unsubmit reviews using AJAX
  def unsubmit_review
    @response = Response.where(map_id: params[:id]).last
    review_response_map = ReviewResponseMap.find_by(id: params[:id])
    reviewer = review_response_map.reviewer.name
    reviewee = review_response_map.reviewee.name
    if @response.update_attribute('is_submitted', false)
      flash.now[:success] = "The review by \"" + reviewer + "\" for \"" + reviewee + "\" has been unsubmitted."
    else
      flash.now[:error] = "The review by \"" + reviewer + "\" for \"" + reviewee + "\" could not be unsubmitted."
    end
    render action: 'unsubmit_review.js.erb', layout: false
  end
  # E1721 changes End

  def delete_reviewer
    review_response_map = ReviewResponseMap.find_by(id: params[:id])
    if review_response_map and Response.exists?(map_id: review_response_map.id)
      # Iterate through every response and related answers and check whether they are empty or not
      Response.where(map_id: review_response_map.id).each do |response|
        unless response.additional_comment.empty?
          flash[:error] = "This reviewer has already started the review. Hence, it cannot been deleted."
          redirect_to :back
          return
        end
        Answer.where(response_id: response.id).each do |answer|
          if !answer.comments.empty? or (answer.answer != 0 and !answer.answer.nil?)
            flash[:error] = "This reviewer has already started the review. Hence, it cannot been deleted."
            redirect_to :back
            return
          end
        end
      end
    end
    if review_response_map
      review_response_map.destroy
      flash[:success] = "The review mapping for \"" + review_response_map.reviewee.name + "\" and \"" + review_response_map.reviewer.name + "\" has been deleted."
    else
      flash[:error] = "No review found."
    end
    redirect_to :back
  end

  def delete_metareviewer
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    flash[:note] = "The metareview mapping for " + mapping.reviewee.name + " and " + mapping.reviewer.name + " has been deleted."

    begin
      mapping.delete
    rescue StandardError
      flash[:error] = "A delete action failed:<br/>" + $ERROR_INFO.to_s + "<a href='/review_mapping/delete_metareview/" + mapping.map_id.to_s + "'>Delete this mapping anyway>?"
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
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @items = AssignmentTeam.where(parent_id: @assignment.id)
    @items.sort_by(&:name)
  end

  def automatic_review_mapping
    assignment_id = params[:id].to_i
    participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
    teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
    # Create teams if its an individual assignment.
    if teams.empty? and max_team_size == 1
      participants.each do |participant|
        user = participant.user
        next if TeamsUser.team_id(assignment_id, user.id)
        team = AssignmentTeam.create_team_and_node(assignment_id)
        ApplicationController.helpers.create_team_users(user, team.id)
        teams << team
      end
    end
    num_reviews_per_student = params[:num_reviews_per_student].to_i
    submission_review_num = params[:num_reviews_per_submission].to_i
    calibrated_artifacts_num = params[:num_calibrated_artifacts].to_i
    uncalibrated_artifacts_num = params[:num_uncalibrated_artifacts].to_i
    if calibrated_artifacts_num.zero? and uncalibrated_artifacts_num.zero?
      # check for exit paths first
      if num_reviews_per_student == 0 and submission_review_num == 0
        flash[:error] = "Please choose either the number of reviews per student or the number of reviewers per team (student)."
      elsif num_reviews_per_student != 0 and submission_review_num != 0
        flash[:error] = "Please choose either the number of reviews per student or the number of reviewers per team (student), not both."
      elsif num_reviews_per_student >= teams.size
        # Exception detection: If instructor want to assign too many reviews done
        # by each student, there will be an error msg.
        flash[:error] = 'You cannot set the number of reviews done ' \
                         'by each student to be greater than or equal to total number of teams ' \
                         '[or "participants" if it is an individual assignment].'
      else
        # REVIEW: mapping strategy
        automatic_review_mapping_strategy(assignment_id, participants, teams, num_reviews_per_student, submission_review_num)
      end
    else
      teams_with_calibrated_artifacts = []
      teams_with_uncalibrated_artifacts = []
      ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 1).each do |response_map|
        teams_with_calibrated_artifacts << AssignmentTeam.find(response_map.reviewee_id)
      end
      teams_with_uncalibrated_artifacts = teams - teams_with_calibrated_artifacts
      # REVIEW: mapping strategy
      automatic_review_mapping_strategy(assignment_id, participants, teams_with_calibrated_artifacts.shuffle!, calibrated_artifacts_num, 0)
      # REVIEW: mapping strategy
      # since after first mapping, participants (delete_at) will be nil
      participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.select(&:can_review).shuffle!
      automatic_review_mapping_strategy(assignment_id, participants, teams_with_uncalibrated_artifacts.shuffle!, uncalibrated_artifacts_num, 0)
    end
    redirect_to action: 'list_mappings', id: assignment_id
  end

  def automatic_review_mapping_strategy(assignment_id,
                                        participants, teams, num_reviews_per_student = 0,
                                        submission_review_num = 0)
    participants_hash = {}
    participants.each {|participant| participants_hash[participant.id] = 0 }
    # calculate reviewers for each team
    if num_reviews_per_student != 0 and submission_review_num == 0
      review_strategy = ReviewMappingHelper::StudentReviewStrategy.new(participants, teams, num_reviews_per_student)
    elsif num_reviews_per_student == 0 and submission_review_num != 0
      review_strategy = ReviewMappingHelper::TeamReviewStrategy.new(participants, teams, submission_review_num)
    end

    # student_review_num was ambiguous. Changed it to num_reviews_per_student.
    # Following test was added to avoid bug when review_strategy is null.  But, the if statement immediately above
    # should be fixed.  StudentReviewStrategy is very likely an artifact of "individual assignments," which were
    # removed from Expertiza years ago.  Try removing that branch of the if statement, as wall as all other refs to them. -efg
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

  def save_grade_and_comment_for_reviewer
    review_grade = ReviewGrade.find_by(participant_id: params[:participant_id])
    review_grade = ReviewGrade.create(participant_id: params[:participant_id]) if review_grade.nil?
    review_grade.grade_for_reviewer = params[:grade_for_reviewer] if params[:grade_for_reviewer]
    review_grade.comment_for_reviewer = params[:comment_for_reviewer] if params[:comment_for_reviewer]
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

  # E1600
  # Start self review if not started yet - Creates a self-review mapping when user requests a self-review
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
        raise "Self review already assigned!"
      end
      redirect_to controller: 'submitted_content', action: 'edit', id: params[:reviewer_id]
    rescue StandardError => e
      redirect_to controller: 'submitted_content', action: 'edit', id: params[:reviewer_id], msg: e.message
    end
  end

  private

  def assign_reviewers_for_team(assignment_id, review_strategy, participants_hash)
    if ReviewResponseMap.where(reviewed_object_id: assignment_id, calibrate_to: 0)
                        .where("created_at > :time",
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
      teams_hash = unsorted_teams_hash.sort_by {|_, v| v }.to_h

      participants_with_insufficient_review_num.each do |participant_id|
        teams_hash.each_key do |team_id, _num_review_received|
          next if TeamsUser.exists?(team_id: team_id,
                                    user_id: Participant.find(participant_id).user_id)

          ReviewResponseMap.where(reviewee_id: team_id, reviewer_id: participant_id,
                                  reviewed_object_id: assignment_id).first_or_create

          teams_hash[team_id] += 1
          teams_hash = teams_hash.sort_by {|_, v| v }.to_h
          break
        end
      end
    end
    @@time_create_last_review_mapping_record = ReviewResponseMap.
                                               where(reviewed_object_id: assignment_id).
                                               last.created_at
  end

  def peer_review_strategy(assignment_id, review_strategy, participants_hash)
    teams = review_strategy.teams
    participants = review_strategy.participants
    num_participants = participants.size

    iterator = 0
    teams.each do |team|
      selected_participants = []
      if !team.equal? teams.last
        # need to even out the # of reviews for teams
        while selected_participants.size < review_strategy.reviews_per_team
          num_participants_this_team = TeamsUser.where(team_id: team.id).size
          # If there are some submitters or reviewers in this team, they are not treated as normal participants.
          # They should be removed from 'num_participants_this_team'
          TeamsUser.where(team_id: team.id).each do |team_user|
            temp_participant = Participant.where(user_id: team_user.user_id, parent_id: assignment_id).first
            num_participants_this_team -= 1 if temp_participant.can_review == false or temp_participant.can_submit == false
          end
          # if all outstanding participants are already in selected_participants, just break the loop.
          break if selected_participants.size == participants.size - num_participants_this_team

          # generate random number
          if iterator.zero?
            rand_num = rand(0..num_participants - 1)
          else
            min_value = participants_hash.values.min
            # get the temp array including indices of participants, each participant has minimum review number in hash table.
            participants_with_min_assigned_reviews = []
            participants.each do |participant|
              participants_with_min_assigned_reviews << participants.index(participant) if participants_hash[participant.id] == min_value
            end
            # if participants_with_min_assigned_reviews is blank
            if_condition_1 = participants_with_min_assigned_reviews.empty?
            # or only one element in participants_with_min_assigned_reviews, prohibit one student to review his/her own artifact
            if_condition_2 = (participants_with_min_assigned_reviews.size == 1 and TeamsUser.exists?(team_id: team.id, user_id: participants[participants_with_min_assigned_reviews[0]].user_id))
            rand_num = if if_condition_1 or if_condition_2
                         # use original method to get random number
                         rand(0..num_participants - 1)
                       else
                         # rand_num should be the position of this participant in original array
                         participants_with_min_assigned_reviews[rand(0..participants_with_min_assigned_reviews.size - 1)]
                       end
          end
          # prohibit one student to review his/her own artifact
          next if TeamsUser.exists?(team_id: team.id, user_id: participants[rand_num].user_id)

          if_condition_1 = (participants_hash[participants[rand_num].id] < review_strategy.reviews_per_student)
          if_condition_2 = (!selected_participants.include? participants[rand_num].id)
          if if_condition_1 and if_condition_2
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
          if !TeamsUser.exists?(team_id: team.id, user_id: participant.user_id) and selected_participants.size < review_strategy.reviews_per_team
            selected_participants << participant.id
            participants_hash[participant.id] += 1
          end
        end
      end

      begin
        selected_participants.each {|index| ReviewResponseMap.where(reviewee_id: team.id, reviewer_id: index, reviewed_object_id: assignment_id).first_or_create }
      rescue StandardError
        flash[:error] = "Automatic assignment of reviewer failed."
      end
      iterator += 1
    end
  end
end
