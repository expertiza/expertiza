class Assessment360Controller < ApplicationController
  include GradesHelper

  # Added the @instructor to display the instructor name in the home page of the 360 degree assessment
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # Find the list of all students and assignments pertaining to the course.
  # This data is used to compute the metareview and teammate review scores.
  def all_students_all_reviews
    course = Course.find(params[:course_id])
    @assignments = course.assignments.reject(&:is_calibrated).reject {|a| a.participants.empty? }
    @course_participants = course.get_participants
    if @course_participants.empty?
      flash[:error] = "There is no course participant in course #{course.name}"
      redirect_to(:back)
    end
    # hashes for view
    @meta_review = {}
    @teammate_review = {}
    @teamed_count = {}
    # for course
    # eg. @overall_teammate_review_grades = {assgt_id1: 100, assgt_id2: 178, ...}
    # @overall_teammate_review_count = {assgt_id1: 1, assgt_id2: 2, ...}
    %w[teammate meta].each do |type|
      instance_variable_set("@overall_#{type}_review_grades", {})
      instance_variable_set("@overall_#{type}_review_count", {})
    end
    @course_participants.each do |cp|
      # for each assignment
      # [aggregrate_review_grades_per_stu, review_count_per_stu] --> [0, 0]
      %w[teammate meta].each {|type| instance_variable_set("@#{type}_review_info_per_stu", [0, 0]) }
      students_teamed = StudentTask.teamed_students(cp.user)
      @teamed_count[cp.id] = students_teamed[course.id].try(:size).to_i
      @assignments.each do |assignment|
        @meta_review[cp.id] = {} unless @meta_review.key?(cp.id)
        @teammate_review[cp.id] = {} unless @teammate_review.key?(cp.id)
        assignment_participant = assignment.participants.find_by(user_id: cp.user_id)
        next if assignment_participant.nil?
        teammate_reviews = assignment_participant.teammate_reviews
        meta_reviews = assignment_participant.metareviews
        populate_hash_for_all_students_all_reviews(assignment,
                                                   cp,
                                                   teammate_reviews,
                                                   @teammate_review,
                                                   @overall_teammate_review_grades,
                                                   @overall_teammate_review_count,
                                                   @teammate_review_info_per_stu)
        populate_hash_for_all_students_all_reviews(assignment,
                                                   cp,
                                                   meta_reviews,
                                                   @meta_review,
                                                   @overall_meta_review_grades,
                                                   @overall_meta_review_count,
                                                   @meta_review_info_per_stu)
      end
      # calculate average grade for each student on all assignments in this course
      if @teammate_review_info_per_stu[1] > 0
        temp_avg_grade = @teammate_review_info_per_stu[0] * 1.0 / @teammate_review_info_per_stu[1]
        @teammate_review[cp.id][:avg_grade_for_assgt] = temp_avg_grade.round.to_s + '%'
      end
      if @meta_review_info_per_stu[1] > 0
        temp_avg_grade = @meta_review_info_per_stu[0] * 1.0 / @meta_review_info_per_stu[1]
        @meta_review[cp.id][:avg_grade_for_assgt] = temp_avg_grade.round.to_s + '%'
      end
    end
    # avoid divide by zero error
    @assignments.each do |assignment|
      temp_count = @overall_teammate_review_count[assignment.id]
      @overall_teammate_review_count[assignment.id] = 1 if temp_count.nil? or temp_count.zero?
      temp_count = @overall_meta_review_count[assignment.id]
      @overall_meta_review_count[assignment.id] = 1 if temp_count.nil? or temp_count.zero?
    end
  end

  # Find the list of all students and assignments pertaining to the course.
  # This data is used to compute the instructor assigned grade and peer review scores.
  # There are many nuances about how to collect these scores. See our design document for more deails
  # http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2018_E1871_Grade_Summary_By_Student
  def course_student_grade_summary
    @topics = {}
    @assignment_grades = {}
    @peer_review_scores = {}
    @final_grades = {}

    course = Course.find(params[:course_id])
    @assignments = course.assignments.reject(&:is_calibrated).reject {|a| a.participants.empty? }
    @course_participants = course.get_participants
    if @course_participants.empty?
      flash[:error] = "There is no course participant in course #{course.name}"
      redirect_to(:back)
    end

    @course_participants.each do |cp|
      @topics[cp.id] = {}
      @assignment_grades[cp.id] = {}
      @peer_review_scores[cp.id] = {}
      @final_grades[cp.id] = 0

      @assignments.each do |assignment|
        user_id = cp.user_id
        assignment_id = assignment.id

        assignment_participant = assignment.participants.find_by(user_id: user_id)
        next if assignment.participants.find_by(user_id: user_id).nil?

        # A topic exists if a team signed up for a topic, which can be found via the user and the assignment
        topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
        @topics[cp.id][assignment_id] = SignUpTopic.find_by(id: topic_id)

        # Instructor grade is stored in the team model, which is found by finding the user's team for the assignment
        team_id = TeamsUser.team_id(assignment_id, user_id)
        next if team_id.nil?

        team = Team.find(team_id)
        peer_review_score = find_peer_review_score(user_id, assignment_id)

        # Set the assignment grade, peer review score, and sum for the final student summary
        @assignment_grades[cp.id][assignment_id] = team[:grade_for_submission]
        unless @assignment_grades[cp.id][assignment_id].nil?
          @final_grades[cp.id] += @assignment_grades[cp.id][assignment_id]
        end

        unless (peer_review_score.nil? || peer_review_score[:review][:scores][:avg].nil?)
          @peer_review_scores[cp.id][assignment_id] = peer_review_score[:review][:scores][:avg].round(2)
        end
      end
    end
  end

  def populate_hash_for_all_students_all_reviews(assignment,
                                                 course_participant,
                                                 reviews,
                                                 hash_per_stu,
                                                 overall_review_grade_hash,
                                                 overall_review_count_hash,
                                                 review_info_per_stu)
    overall_review_grade_hash[assignment.id] = 0 unless overall_review_grade_hash.key?(assignment.id)
    overall_review_count_hash[assignment.id] = 0 unless overall_review_count_hash.key?(assignment.id)
    grades = 0
    if reviews.count > 0
      reviews.each {|review| grades += review.average_score.to_i }
      avg_grades = (grades * 1.0 / reviews.count).round
      hash_per_stu[course_participant.id][assignment.id] = avg_grades.to_s + '%'
    end
    if avg_grades and grades > 0
      # for each assignment
      review_info_per_stu[0] += avg_grades
      review_info_per_stu[1] += 1
      # for course
      overall_review_grade_hash[assignment.id] += avg_grades
      overall_review_count_hash[assignment.id] += 1
    end
  end

  # The peer review score is taken from the questions for the assignment
  def find_peer_review_score(user_id, assignment_id)
    participant = AssignmentParticipant.find_by(user_id: user_id, parent_id: assignment_id)
    assignment = participant.assignment
    questions = retrieve_questions assignment.questionnaires, assignment_id

    participant.scores(questions)
  end

  def format_topic(topic)
    topic.nil? ? '-' : topic.format_for_display
  end

  def format_score(score)
    score.nil? ? '-' : score
  end

  helper_method :format_score
  helper_method :format_topic
end
