class LeaderboardController < ApplicationController
  before_filter :authorize

  def action_allowed?
    true
  end

  # Allows to view leaderBoard - sorted on max number of badges received by a course participant
  # E1626
  def index
    if current_user
      @instructor_query = LeaderboardHelper.user_is_instructor?(current_user.id)

      if @instructor_query
        @course_list = LeaderboardHelper.instructor_courses(current_user.id)
      else
        @course_list = LeaderboardHelper.student_in_which_courses(current_user.id)
      end
      @course_info = Leaderboard.getCourseInfo(@course_list)
    end
  end

  def view
    ##Get Course participants
    #@instructor = User.find_by_id(params[:user_id])
    @course = Course.find_by_id(params[:course_id])
    @instructor = Instructor.find_by_id(@course.instructor_id)
    @participants = Participant.where('parent_id = ?', params[:course_id]).pluck(:user_id)
    @students = User.where('id in (?) and role_id = ?', @participants, 1)
    @assignments = Assignment.where('course_id = ?', params[:course_id])

    #get assignment stages
    assignment_stage = LeaderboardHelper.get_stage_assignments(@assignments, @students)

    @student_badges = Hash[@students.pluck(:id).map { |x| [x, nil] }]
    @track_badge_users = Array.new

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
          participant_scores = Hash.new
          @assignment_groups.each do |assign_group|
            participant_assignment = Participant.where('parent_id = ?', assign_group.assignment_id)
            participant_assignment.each do |p|
              score = LeaderboardHelper.get_scores p.id
              begin
                if score != nil and score.key?(:total_score)
                  if !participant_scores.key?(p.user_id)
                    participant_scores[p.user_id] = score[:total_score]
                  else
                    #Average or Sum
                    participant_scores[p.user_id] = participant_scores[p.user_id] + score[:total_score]
                  end
                end
              rescue
                if score.is_a? Float
                  if !participant_scores.key?(p.user_id)
                    participant_scores[p.user_id] = score
                  else
                    #Average or Sum
                    participant_scores[p.user_id] = participant_scores[p.user_id] + score
                  end
                end
              end
            end
          end
          sorted_scores = Hash[participant_scores.sort_by { |k, v| v }.reverse!]
          #Average Score Calculation

          if @assignment_groups.count == 1
            final_users = LeaderboardHelper.get_eligible_users_for_badge badge_group, sorted_scores, @assignment_groups[0].assignment_id
          else
            if badge_group.strategy == 'Top Scores'
              final_users = LeaderboardHelper.get_users_top_scores_team_of_one sorted_scores, badge_group.threshold
            elsif badge_group.strategy == 'Score Threshold'
              final_users = LeaderboardHelper.get_users_threshold_team_of_one sorted_scores, badge_group.threshold
            end
          end


          final_users.each do |u|
            if @assignment_groups.count == 1
              @track_badge_users = LeaderboardHelper.assign_badge_user badge_group.badge_id, u, 1, @assignment_groups[0].assignment_id, params[:course_id], @track_badge_users, @course
            elsif @assignment_groups.count > 1
              @track_badge_users = LeaderboardHelper.assign_badge_user badge_group.badge_id, u, 0, nil, params[:course_id], @track_badge_users, @course
            end

            if @student_badges[u] == nil
              badge_array = Array.new
              badge_array.push(badge_group.badge_id)
              @student_badges[u] = badge_array
            else
              badge_array = @student_badges[u]
              badge_array.push(badge_group.badge_id)
              @student_badges[u] = badge_array
            end
          end
          badge_group.badges_awarded = true
          badge_group.save!
        end
      else
        if badge_group.is_course_level_group == false
          @assignment_groups = AssignmentGroup.where('badge_group_id = ?', badge_group.id)
          students_with_badges = BadgeUser.where('assignment_id = ? and course_id = ? and badge_id = ?', @assignment_groups[0].assignment_id, params[:course_id], badge_group.badge_id)
          students_with_badges.each do |student|
            @track_badge_users.push(student.id)
            if @student_badges[student.user_id] == nil
              badge_array = Array.new
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
            @track_badge_users.push(student.id)
            if @student_badges[student.user_id] == nil
              badge_array = Array.new
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
    @track_badge_users, @student_badges = LeaderboardHelper.instructor_added_badges(@track_badge_users, @student_badges)

    #get badge URLs
    @badgeURL, @badge_names = LeaderboardHelper.get_badges_info @course

    @student_badges.delete_if { |k, v| v.nil? }
    @sorted_student_badges = Hash[@student_badges.sort_by { |k, v| v }.reverse]
    @badgeURL
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

end
