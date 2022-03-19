class Assessment360Controller < ApplicationController
  include GradesHelper
  include AuthorizationHelper
  include Scoring
  # Added the @instructor to display the instructor name in the home page of the 360 degree assessment
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Find the list of all students and assignments pertaining to the course.
  # This data is used to compute the metareview and teammate review scores.
  def all_students_all_reviews_old
    load_course_assignments_and_course_participants

    # hashes for view
    @meta_review = reviews_for_type_old('meta')
    @teammate_review = reviews_for_type_old('teammate')
  end

  # Change metareviews to meta_reviews in assignment_participants and its references
  # so that reviews_variable can be removed
  def reviews_for_type_old(type)
    # hashes for view
    reviews_variable = type + '_reviews'
    @teamed_count = {} # TODO: https://github.com/sak007/expertiza/issues/2
    review = {}
    # for course
    # eg. @overall_teammate_review_grades = {assgt_id1: 100, assgt_id2: 178, ...}
    # @overall_teammate_review_count = {assgt_id1: 1, assgt_id2: 2, ...}
    instance_variable_set("@overall_#{type}_review_grades", {})
    instance_variable_set("@overall_#{type}_review_count", {})

    reviews_by_user_id_and_assignment(reviews_variable)

    @course_participants.each do |cp|
      # for each assignment
      # [aggregrate_review_grades_per_stu, review_count_per_stu] --> [0, 0]
      instance_variable_set("@#{type}_review_info_per_stu", [0, 0])
      review[cp.id] = {}
      students_teamed = StudentTask.teamed_students(cp.user)
      @teamed_count[cp.id] = students_teamed[@course.id].try(:size).to_i # TODO: https://github.com/sak007/expertiza/issues/2
      @assignments.each do |assignment|
        # skip if the student is not participated in any assignment
        next if review_by_user_id_and_assignment[cp.user_id].nil?
        # skip if the student is not participated in the current assignment
        next if review_by_user_id_and_assignment[cp.user_id][assignment.id].nil?
        reviews = review_by_user_id_and_assignment[cp.user_id][assignment.id]
        calc_overall_review_info(assignment,
                                 cp,
                                 reviews,
                                 review,
                                 instance_variable_get("@overall_#{type}_review_grades"),
                                 instance_variable_get("@overall_#{type}_review_count"),
                                 instance_variable_get("@#{type}_review_info_per_stu"))
      end
      # calculate average grade for each student on all assignments in this course
      avg_review_calc_per_student(cp, instance_variable_get("@#{type}_review_info_per_stu"), review)
    end
    # avoid divide by zero error
    overall_review_count(@assignments, instance_variable_get("@overall_#{type}_review_count"))
    return review
  end

  # to avoid divide by zero error
  def overall_review_count(assignments, overall_review_count)
    assignments.each do |assignment|
      temp_count = overall_review_count[assignment.id]
      overall_review_count[assignment.id] = 1 if temp_count.nil? || temp_count.zero?
    end
  end

  # Calculate the overall average review grade that a student has gotten from their teammate(s) and instructor(s)
  def avg_review_calc_per_student(cp, review_info_per_stu, review)
    # check to see if the student has been given a review
    if review_info_per_stu[1] > 0
      temp_avg_grade = review_info_per_stu[0] * 1.0 / review_info_per_stu[1]
      review[cp.id][:avg_grade_for_assgt] = temp_avg_grade.round.to_s + '%'
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
    load_course_assignments_and_course_participants
    @course_participants.each do |cp|
      @topics[cp.id] = {}
      @assignment_grades[cp.id] = {}
      @peer_review_scores[cp.id] = {}
      @final_grades[cp.id] = 0
      @assignments.each do |assignment|
        user_id = cp.user_id
        assignment_id = assignment.id
        next if assignment.participants.find_by(user_id: user_id).nil? # break out of the loop if there are no participants in the assignment
        next if TeamsUser.team_id(assignment_id, user_id).nil? # break out of the loop if the participant has no team

        assignment_grade_summary(cp, assignment_id) # pull information about the student's grades for particular assignment
        peer_review_score = find_peer_review_score(user_id, assignment_id)

        next if peer_review_score.nil? # Skip if there are no peers
        next if peer_review_score[:review].nil? # Skip if there are no reviews done by peer
        next if peer_review_score[:review][:scores].nil? # Skip if there are no reviews scores assigned by peer
        next if peer_review_score[:review][:scores][:avg].nil? # Skip if there are is no peer review average score

        @peer_review_scores[cp.id][assignment_id] = peer_review_score[:review][:scores][:avg].round(2)
      end
    end
  end

  def assignment_grade_summary(cp, assignment_id)
    user_id = cp.user_id
    # topic exists if a team signed up for a topic, which can be found via the user and the assignment
    topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
    @topics[cp.id][assignment_id] = SignUpTopic.find_by(id: topic_id)
    # instructor grade is stored in the team model, which is found by finding the user's team for the assignment
    team_id = TeamsUser.team_id(assignment_id, user_id)
    team = Team.find(team_id)
    @assignment_grades[cp.id][assignment_id] = team[:grade_for_submission]
    return if @assignment_grades[cp.id][assignment_id].nil?

    @final_grades[cp.id] += @assignment_grades[cp.id][assignment_id]
  end

  def insure_existence_of(course_participants, course)
    if course_participants.empty?
      flash[:error] = "There is no course participant in course #{course.name}"
      redirect_to(:back)
    end
  end

  # The function populates the hash value for all students for all the reviews that they have gotten.
  # I.e., Teammate and Meta for each of the assignments that they have taken
  # This value is then used to display the overall teammate_review and meta_review grade in the view
  def calc_overall_review_info(assignment,
                               course_participant,
                               reviews,
                               hash_per_stu,
                               overall_review_grade_hash,
                               overall_review_count_hash,
                               review_info_per_stu)
    # If a student has not taken an assignment or if they have not received any grade for the same,
    # assign it as 0 instead of leaving it blank. This helps in easier calculation of overall grade
    overall_review_grade_hash[assignment.id] = 0 unless overall_review_grade_hash.key?(assignment.id)
    overall_review_count_hash[assignment.id] = 0 unless overall_review_count_hash.key?(assignment.id)
    grades = 0
    # Check if they person has gotten any review for the assignment
    if reviews.count > 0
      reviews.each { |review| grades += review.average_score.to_i }
      avg_grades = (grades * 1.0 / reviews.count).round
      hash_per_stu[course_participant.id][assignment.id] = avg_grades.to_s + '%'
    end
    # Calculate sum of averages to get student's overall grade
    if avg_grades && (grades >= 0)
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
    participant_scores(participant, questions)
  end

  def load_course_assignments_and_course_participants
    @course = Course.find(params[:course_id])
    @assignments = @course.assignments.includes([:participants]).reject(&:is_calibrated).reject { |a| a.participants.empty? }
    @course_participants = @course.get_participants
    insure_existence_of(@course_participants, @course)
  end

  def format_topic(topic)
    topic.nil? ? '-' : topic.format_for_display
  end

  def format_score(score)
    score.nil? ? '-' : score
  end

  def format_percentage(score)
    score.nil? ? '-' : score.to_s + '%'
  end

  helper_method :format_score
  helper_method :format_topic
  helper_method :format_percentage

  def index
    load_course
    load_assignments
    load_course_participants
    calc_teammate_count

    @meta_review = reviews_for_type('meta')
    @meta_review[:aggregate_score] = calc_aggregate_score(@meta_review)
    @meta_review[:class_avg] = calc_class_avg_score(@meta_review)
    @meta_review[:aggregate_score_class_avg] = calc_aggregate_score_class_avg(@meta_review)

    @teammate_review = reviews_for_type('teammate')
    @teammate_review[:aggregate_score] = calc_aggregate_score(@teammate_review)
    @teammate_review[:class_avg] = calc_class_avg_score(@teammate_review)
    @teammate_review[:aggregate_score_class_avg] = calc_aggregate_score_class_avg(@teammate_review)
  end

  private
    def reviews_for_type(type)
      reviews_variable = type + '_reviews'
      review = {}

      review_by_user_id_and_assignment = reviews_by_user_id_and_assignment(reviews_variable)

      @course_participants.each do |cp|
        review[cp.id] = {}
        # cp_assignment_count = 0
        # total_cp_review_score = 0
        # for each assignment
        # [aggregrate_review_grades_per_stu, review_count_per_stu] --> [0, 0]
        # instance_variable_set("@#{type}_review_info_per_stu", [0, 0])
        # review[cp.id] = {}
        @assignments.each do |assignment|
          # skip if the student is not participated in any assignment
          next if review_by_user_id_and_assignment[cp.user_id].nil?

          # skip if the student is not participated in the current assignment
          next if review_by_user_id_and_assignment[cp.user_id][assignment.id].nil?

          reviews = review_by_user_id_and_assignment[cp.user_id][assignment.id]
          # score = calc_avg_score(reviews)

          # skip if the student does not have any review for the assignment
          # next if score.nil?

          # cp_assignment_count += 1
          # total_cp_review_score += score
          score = calc_avg_score(reviews)
          review[cp.id][assignment.id] = score unless score.nil?
        end
        # calculate average grade for each student on all assignments in this course
        # avg_review_calc_per_student(cp, instance_variable_get("@#{type}_review_info_per_stu"), review)
        # if cp_assignment_count > 0
        #   review[cp.id][:aggregate_score] =(total_cp_review_score * 1.0 / cp_assignment_count).round
        # end

      end
      # avoid divide by zero error
      # overall_review_count(@assignments, instance_variable_get("@overall_#{type}_review_count"))
      return review
    end

    def load_course
      @course = Course.find(params[:course_id])
    end

    def load_assignments
      # Load participants along with the assignments(eager loading)
      # TODO: What does calibrate does?
      # Reject assignments with empty participants
      @assignments = @course.assignments.includes([:participants]).reject(&:is_calibrated).reject { |a| a.participants.empty? }
    end

    def load_course_participants
      @course_participants = @course.get_participants
      insure_existence_of(@course_participants, @course)
    end

    def reviews_by_user_id_and_assignment(reviews_variable)
      reviews = {}
      @assignments.each do |assignment|
        assignment.participants.all.each do |assignment_participant|
          reviews[assignment_participant.user_id] = {} unless reviews.key?(assignment_participant.user_id)
          assignment_reviews = assignment_participant.public_send(reviews_variable) if assignment_participant.respond_to? reviews_variable
          reviews[assignment_participant.user_id][assignment.id] = assignment_reviews
        end
      end
      return reviews
    end

    def calc_avg_score(reviews)
      # If a student has not taken an assignment or if they have not received any grade for the same,
      # assign it as 0 instead of leaving it blank. This helps in easier calculation of overall grade
      grades = 0
      # Check if they person has gotten any review for the assignment
      if reviews.count > 0
        reviews.each { |review| grades += review.average_score.to_i }
        return (grades * 1.0 / reviews.count).round
      end
    end

    # TODO: https://github.com/sak007/expertiza/issues/2
    def calc_teammate_count
      @teamed_count = {}
      @course_participants.each do |cp|
        students_teamed = StudentTask.teamed_students(cp.user)
        @teamed_count[cp.id] = students_teamed[@course.id].try(:size).to_i
      end
    end

    def calc_aggregate_score(review)
      aggregate_scores = {}
      review.each do |cp_id, assignment_review_scores_map|
        aggregate_scores[cp_id] = (assignment_review_scores_map.inject(0) {|sum , (k,v)| sum += v } * 1.0 / assignment_review_scores_map.size).round unless assignment_review_scores_map.empty?
      end
      return aggregate_scores
    end

    def calc_class_avg_score(review)
      assignment_review_scores = {}
      total_review_scores = {}
      review_counts = {}

      review.each do |cp_id, assignment_review_scores_map|
        assignment_review_scores_map.each do |assignment_id, score|
          total_review_scores[assignment_id] = 0 unless total_review_scores.key?(assignment_id)
          review_counts[assignment_id] = 0 unless review_counts.key?(assignment_id)
          total_review_scores[assignment_id] += score
          review_counts[assignment_id] += 1
        end
      end

      @assignments.each do |assignment|
        assignment_review_scores[assignment.id] = (total_review_scores[assignment.id] * 1.0 / review_counts[assignment.id]).round if review_counts.key?(assignment.id)
      end

      return assignment_review_scores
    end

    def calc_aggregate_score_class_avg(review)
      return (review[:aggregate_score].values.sum * 1.0 / review[:aggregate_score].size).round unless review[:aggregate_score].empty?
    end
end
