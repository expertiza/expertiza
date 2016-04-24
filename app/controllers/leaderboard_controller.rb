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
    @instructor = User.find_by_id(params[:user_id])
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


    #GetBadgeGroups
    @badge_groups = BadgeGroup.where('course_id = ? and is_course_level_group = ?', params[:course_id], 0)
    @badge_groups.each do |badge_group|
      @assignment_groups = AssignmentGroup.where('badge_group_id = ?', badge_group.id)


    end



    #GetScoresForAssignmentLevelBadges

    #@participant = AssignmentParticipant.find(params[:id])
    #@team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    #@assignment = @participant.assignment
    ##@questions = {} # A hash containing all the questions in all the questionnaires used in this assignment
    #questionnaires = @assignment.questionnaires
    #retrieve_questions (questionnaires)

    #@pscore has the newest versions of response for each response map, and only one for each response map (unless it is vary rubric by round)
    #@pscore = @participant.scores(@questions)

    j = 0
  end

end
