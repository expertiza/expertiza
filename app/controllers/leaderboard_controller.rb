class LeaderboardController < ApplicationController
  before_filter :authorize

  def action_allowed?
    true
  end

  # Allows to view leaderBoard - sorted on max number of badges received by a course participant
  # E1626
  def index
    if current_user
      @instructor_query = LeaderboardHelper.userIsInstructor?(current_user.id)

      if @instructor_query
        @course_list = LeaderboardHelper.instructorCourses(current_user.id)
      else
        @course_list = LeaderboardHelper.studentInWhichCourses(current_user.id)
      end
      @course_info = Leaderboard.getCourseInfo(@course_list)
    end
  end

  def view
    ##Get Course participants
    #@instructor = User.find_by_id(params[:user_id])
    @course = Course.find_by_id(params[:course_id])
    @participants = Participant.where('parent_id = ?', params[:course_id]).pluck(:user_id)
    @students = User.where('id in (?) and role_id = ?', @participants, 1)
    @assignments = Assignment.where('course_id = ?', params[:course_id])
    assignment_stage = Hash.new()

    #get assignment stages
    @assignments.each do |assignment|
      @students.each do |student|
        participant_assignment = Participant.where('parent_id = ? and user_id = ?', assignment.id, student.id).first
        topic_id = SignedUpTeam.topic_id(participant_assignment.parent_id, participant_assignment.user_id)
        stagename = participant_assignment.assignment.get_current_stage_name(topic_id)
        assignment_stage[assignment.id] = stagename
        break
      end
    end

    @student_badges = Hash[@students.pluck(:id).map {|x| [x, nil]}]
    @track_badge_users = Array.new()

    #GetBadgeGroups
    @badge_groups = BadgeGroup.where('course_id = ?', params[:course_id])
    @badge_groups.each do |badge_group|

      if badge_group.badges_awarded == false

        @assignment_groups = AssignmentGroup.where('badge_group_id = ?', badge_group.id)

        assignment_id = @assignment_groups.pluck(:assignment_id)
        assignment_status = 1

        assignment_id.each do |a|
          if assignment_stage[a] != 'Finished'
            assignment_status = 0
          end
        end

        if assignment_status == 1
          @assignment_groups.each do |assign_group|
            participant_scores = Hash.new()
            participant_assignment = Participant.where('parent_id = ?', assign_group.assignment_id)
            participant_assignment.each do |p|
              score = get_scores p.id
              begin
                if score != nil and score.key?(:total_score)
                  if !participant_scores.key?(p.user_id)
                    participant_scores[p.user_id] = score[:total_score]
                  else
                    participant_scores[p.user_id] = participant_scores[p.user_id] + score[:total_score]
                  end
                end
              rescue
                if score.is_a? Float
                  if !participant_scores.key?(p.user_id)
                    participant_scores[p.user_id] = score
                  else
                    participant_scores[p.user_id] = participant_scores[p.user_id] + score
                  end
                end
              end
            end
            sorted_scores = Hash[participant_scores.sort_by { |k, v| v }.reverse!]
            final_users = get_eligible_users_for_badge badge_group, sorted_scores, assign_group.assignment_id
            final_users.each do |u|
              if(@assignment_groups.count == 1)
                assign_badge_user badge_group.badge_id, u, 1, assign_group.assignment_id, params[:course_id]
              elsif @assignment_groups.count > 1
                assign_badge_user badge_group.badge_id, u, 0, nil, params[:course_id]
              end
              if @student_badges[u] == nil
                badge_array = Array.new()
                badge_array.push(badge_group.badge_id)
                @student_badges[u] = badge_array
              else
                badge_array = @student_badges[u]
                badge_array.push(badge_group.badge_id)
                @student_badges[u] = badge_array
              end
            end
          end
        end
      else
        if badge_group.is_course_level_group == 0
          students_with_badges = BadgeUser.where('assignment_id = ? and course_id = ? and badge_id = ?', @assignment_groups[0].assignment_id, params[:course_id], badge_group.badge_id)
          students_with_badges.each do |student|
            @track_badge_users.push(students_with_badges.id)
            if @student_badges[student.user_id] == nil
              badge_array = Array.new()
              badge_array.push(badge_group.badge_id)
              @student_badges[student.user_id] = badge_array
            else
              badge_array = @student_badges[student.user_id]
              badge_array.push(badge_group.badge_id)
              @student_badges[student.user_id] = badge_array
            end
          end
        else
          students_with_badges = BadgeUser.where('is_course_badge = ? and course_id = ? and badge_id = ?', 1, params[:course_id], badge_group.badge_id)
          students_with_badges.each do |student|
            @track_badge_users.push(students_with_badges.id)
            if @student_badges[student.user_id] == nil
              badge_array = Array.new()
              badge_array.push(badge_group.badge_id)
              @student_badges[student.user_id] = badge_array
            else
              badge_array = @student_badges[student.user_id]
              badge_array.push(badge_group.badge_id)
              @student_badges[student.user_id] = badge_array
            end
          end
        end
      end
    end

    #add badges awarded by instructor manually
    badge_user_instructor = BadgeUser.where('id not in (?)', @track_badge_users)
    badge_user_instructor.each do |bi|
      if @student_badges[badge_user_instructor.user_id] == nil
        badge_array = Array.new()
        badge_array.push(badge_user_instructor.badge_id)
        @student_badges[badge_user_instructor.user_id] = badge_array
      else
        badge_array = @student_badges[badge_user_instructor.user_id]
        badge_array.push(badge_user_instructor.badge_id)
        @student_badges[badge_user_instructor.user_id] = badge_array
      end
    end

    #get badge URLs
    @badge_urls = CredlyHelper.get_badges_created(@course.instructor_id)
  end


  def get_eligible_users_for_badge badge_group, sorted_scores, assignment_id
    strategy = badge_group.strategy
    threshold = badge_group.threshold
    count_teams = Team.where('parent_id = ?', assignment_id)
    count_participants = Participant.where('parent_id = ?', assignment_id)
    final_users = nil


    if (count_teams.count == count_participants.count)
      if strategy == 'Top Scores'
        final_users = get_users_top_scores_team_of_one sorted_scores, threshold
      elsif strategy == 'Score Threshold'
        final_users = get_users_threshold_team_of_one sorted_scores, threshold
      end
    else
      if strategy == 'Top Scores'
        final_users = get_users_top_scores_team_of_multiple sorted_scores, threshold, assignment_id
      elsif strategy == 'Score Threshold'
        final_users = get_users_threshold_team_of_multiple sorted_scores, threshold, assignment_id
      end
    end
    final_users
  end

  def get_users_top_scores_team_of_one sorted_scores, threshold
    prev_value = 0
    final_users = Array.new
    rank =0
    sorted_scores.each_with_index do |(k, v), i|
      if i == 0
        prev_value = v
        rank = 1
      end

      if (rank < threshold)
        final_users.push(k)
      else
        break
      end
      if (v < prev_value)
        rank = rank + 1
        prev_value = v
      end
    end
    final_users
  end

  def get_users_threshold_team_of_one sorted_scores, threshold
    final_users = Array.new
    sorted_scores.each_with_index do |(k, v), i|
      if v >= threshold
        final_users.push(k)
        break
      end
    end
    final_users
  end

  def get_users_top_scores_team_of_multiple sorted_scores, threshold, assignment_id
    final_users = Array.new
    prev_value = 0
    rank = 0
    sorted_scores.each_with_index do |(k, v), i|
      if i == 0
        prev_value = v
        rank = 1
      end

      if (rank < threshold)
        if !final_users.include?(k)
          final_users.push(k)
        end
        results = Team.joins(:teams_users).where('teams.parent_id= ? and teams_users.user_id=?', assignment_id, k)
        team_id = results[0].id
        team_users = TeamsUser.where('team_id = ?', team_id)
        team_users.each do |tu|
          if (!final_users.include?(k))
            final_users.push(tu.user_id)
          end
        end
      else
        break
      end
      if (v < prev_value)
        rank = rank + 1
        prev_value = v
      end
    end
    final_users
  end

  def get_users_threshold_team_of_multiple sorted_scores, threshold, assignment_id
    final_users = Array.new
    sorted_scores.each_with_index do |(k, v), i|
      if v >= threshold
        if !final_users.include?(k)
          final_users.push(k)
        end
        results = Team.joins(:teams_users).where('teams.parent_id= ? and teams_users.user_id=?', assignment_id, k)
        team_id = results[0].id
        team_users = TeamsUser.where('team_id = ?', team_id)
        team_users.each do |tu|
          if (!final_users.include?(k))
            final_users.push(tu.user_id)
          end
        end
        break
      end
    end
    final_users
  end

  #GetScoresForAssignmentLevelBadges
  def get_scores participant_id

    @participant = AssignmentParticipant.find(participant_id)
    @team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    @assignment = @participant.assignment
    @questions = {} # A hash containing all the questions in all the questionnaires used in this assignment
    questionnaires = @assignment.questionnaires
    retrieve_questions(questionnaires)

    #@pscore has the newest versions of response for each response map, and only one for each response map (unless it is vary rubric by round)
    @pscore = @participant.scores(@questions)

  end

  def retrieve_questions (questionnaires)
    questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id).first.used_in_round
      if (round!=nil)
        questionnaire_symbol = (questionnaire.symbol.to_s+round.to_s).to_sym
      else
        questionnaire_symbol = questionnaire.symbol
      end
      @questions[questionnaire_symbol] = questionnaire.questions
    end
  end

  def assign_badge_user badge_id, user_id, is_assignment_level_badge, assignment_id, course_id
    badge_user = BadgeUser.new
    badge_user.badge_id = badge_id
    badge_user.user_id = user_id

    if is_assignment_level_badge
      badge_user.is_course_badge = false
      badge_user.assignment_id = assignment_id
    else
      badge_user.is_course_badge = true
      badge_user.course_id = course_id
    end

    badge_user.save!

    @track_badge_users.push(badge_user.id)

    student_credly_id = User.where('id = ?', user_id).first
    credly_badge = Badge.find_by_id(badge_id)

    CredlyHelper.award_badge_user(@course.instructor_id, student_credly_id.credly_id, credly_badge.credly_badge_id)

  end

end
