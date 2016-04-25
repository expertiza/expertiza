module LeaderboardHelper

  # Identify whether current user is instructor
  # E1626
  def self.user_is_instructor?(user_id)
    # Instructors and Super-Admins are considered as instructors
    instructor_names = ['Instructor', 'Super-Administrator']
    instructor_roles = Role.where(:name => instructor_names).pluck(:id)
    user = User.where('id = ?', user_id).first
    instructor = false
    if instructor_roles.index(user.role_id)
      instructor = true
    end
    instructor
  end

  # This methods gets all the courses that an instructor has been assigned.
  # This method assumes the instructor_id in the Courses table indicates
  # the courses an instructor is managing.
  def self.instructor_courses(user_id)
    course_list = Array.new
    course_list = Course.where(:instructor_id => user_id).pluck(:id)
    course_list
  end

  # Returns list of course ids in which the student participated in an assignment
  def self.student_in_which_courses(student_user_id)
    # Get all assignments of participants corresponding to given userId and having an associated courseId
    assignment_records = Assignment.joins(:participants).where('participants.user_id = ? AND course_id IS NOT NULL', student_user_id)

    # Fetch all courses associated with assignments participated by the student
    course_list = assignment_records.pluck(:course_id).uniq
    course_list
  end

  def self.get_stage_assignments(assignments, students)
    assignment_stage = Hash.new
    assignments.each do |assignment|
      students.each do |student|
        participant_assignment = Participant.where('parent_id = ? and user_id = ?', assignment.id, student.id).first
        topic_id = SignedUpTeam.topic_id(participant_assignment.parent_id, participant_assignment.user_id)
        stage_name = participant_assignment.assignment.get_current_stage_name(topic_id)
        assignment_stage[assignment.id] = stage_name
        break
      end
    end
    assignment_stage
  end

  def self.get_eligible_users_for_badge(badge_group, sorted_scores, assignment_id)
    strategy = badge_group.strategy
    threshold = badge_group.threshold
    count_teams = Team.where('parent_id = ?', assignment_id)
    count_participants = Participant.where('parent_id = ?', assignment_id)
    final_users = nil


    if count_teams.count == count_participants.count
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

  def self.get_users_top_scores_team_of_one(sorted_scores, threshold)
    prev_value = 0
    final_users = Array.new
    rank =0
    sorted_scores.each_with_index do |(k, v), i|
      if i == 0
        prev_value = v
        rank = 1
      end

      if rank < threshold
        final_users.push(k)
      else
        break
      end
      if v < prev_value
        rank = rank + 1
        prev_value = v
      end
    end
    final_users
  end

  def self.get_users_threshold_team_of_one(sorted_scores, threshold)
    final_users = Array.new
    sorted_scores.each_with_index do |(k, v), i|
      if v >= threshold
        final_users.push(k)
      end
    end
    final_users
  end

  def self.get_users_top_scores_team_of_multiple(sorted_scores, threshold, assignment_id)
    final_users = Array.new
    prev_value = 0
    rank = 0
    sorted_scores.each_with_index do |(k, v), i|
      if i == 0
        prev_value = v
        rank = 1
      end

      if rank < threshold
        unless final_users.include?(k)
          final_users.push(k)
        end
        results = Team.joins(:teams_users).where('teams.parent_id= ? and teams_users.user_id=?', assignment_id, k)
        team_id = results[0].id
        team_users = TeamsUser.where('team_id = ?', team_id)
        team_users.each do |tu|
          unless final_users.include?(k)
            final_users.push(tu.user_id)
          end
        end
      else
        break
      end
      if v < prev_value
        rank = rank + 1
        prev_value = v
      end
    end
    final_users
  end

  def self.get_users_threshold_team_of_multiple(sorted_scores, threshold, assignment_id)
    final_users = Array.new
    sorted_scores.each_with_index do |(k, v), i|
      if v >= threshold
        unless final_users.include?(k)
          final_users.push(k)
        end
        results = Team.joins(:teams_users).where('teams.parent_id= ? and teams_users.user_id=?', assignment_id, k)
        team_id = results[0].id
        team_users = TeamsUser.where('team_id = ?', team_id)
        team_users.each do |tu|
          unless final_users.include?(k)
            final_users.push(tu.user_id)
          end
        end
      end
    end
    final_users
  end

  #GetScoresForAssignmentLevelBadges
  def self.get_scores(participant_id)
    @participant = AssignmentParticipant.find(participant_id)
    @team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    @assignment = @participant.assignment
    @questions = {} # A hash containing all the questions in all the questionnaires used in this assignment
    questionnaires = @assignment.questionnaires
    @questions = retrieve_questions(questionnaires, @assignment, @questions)

    #@pscore has the newest versions of response for each response map, and only one for each response map (unless it is vary rubric by round)
    @pscore = @participant.scores(@questions)
  end

  def self.retrieve_questions (questionnaires, assignment, questions)
    questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.where(assignment_id: assignment.id, questionnaire_id: questionnaire.id).first.used_in_round
      if round!=nil
        questionnaire_symbol = (questionnaire.symbol.to_s+round.to_s).to_sym
      else
        questionnaire_symbol = questionnaire.symbol
      end
      questions[questionnaire_symbol] = questionnaire.questions
    end
    questions
  end

  def self.assign_badge_user badge_id, user_id, is_assignment_level_badge, assignment_id, course_id, track_badge_users, course
    badge_user = BadgeUser.new
    badge_user.badge_id = badge_id
    badge_user.user_id = user_id

    if is_assignment_level_badge
      badge_user.is_course_badge = false
      badge_user.assignment_id = assignment_id
      badge_user.course_id=course_id
    else
      badge_user.is_course_badge = true
      badge_user.course_id = course_id
    end

    badge_user.save!

    track_badge_users.push(badge_user.id)

    student_credly_id = User.where('id = ?', user_id).first
    credly_badge = Badge.find_by_id(badge_id)

    CredlyHelper.award_badge_user(course.instructor_id, student_credly_id.credly_id, credly_badge.credly_badge_id)
    track_badge_users
  end

  #get badge URLs
  def self.get_badges_info(course)
    badge_json = CredlyHelper.get_badges_created(course.instructor_id)
    badge_json_data = JSON.parse(badge_json.body)['data']
    badge_urls = Hash.new
    badge_names = Hash.new
    badge_json_data.each do |data|
      badge = Badge.where('credly_badge_id = ?', data['id']).first
      badge_urls[badge.id] = data['image_url']
      badge_names[badge.id] = badge.name
    end

    return badge_urls, badge_names
  end

  #get badges awarded by instructor manually
  def self.instructor_added_badges(track_badge_users, student_badges, course_id)
    badge_user_instructor = BadgeUser.where('course_id = ? and id not in (?)', course_id, track_badge_users)
    badge_user_instructor.each do |bi|
      if student_badges[bi.user_id] == nil
        badge_array = Array.new
        badge_array.push(bi.badge_id)
        student_badges[bi.user_id] = badge_array
      else
        badge_array = student_badges[bi.user_id]
        badge_array.push(bi.badge_id)
        student_badges[bi.user_id] = badge_array
      end
    end

    return track_badge_users, student_badges
  end

  def self.get_students_badges(badge_group, students_with_badges, track_badge_users, student_badges)
    students_with_badges.each do |student|
      track_badge_users.push(student.id)
      if student_badges[student.user_id] == nil
        badge_array = Array.new
        badge_array.push(badge_group.badge_id)
        student_badges[student.user_id] = badge_array
      else
        badge_array = student_badges[student.user_id]
        badge_array.push(badge_group.badge_id)
        student_badges[student.user_id] = badge_array
      end
    end
    return track_badge_users, student_badges
  end

  def self.get_participant_scores(participant_scores, assignment_groups)
    assignment_groups.each do |assign_group|
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
    end
    participant_scores
  end

end