class Assessment360Controller < ApplicationController
  include GradesHelper
  include AuthorizationHelper
  include Scoring
  include PenaltyHelper
  include Assessment360Helper
  # Added the @instructor to display the instructor name in the home page of the 360 degree assessment
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Find the list of all students and assignments pertaining to the course.
  # This data is used to compute the metareview and teammate review scores.
  def all_students_all_reviews
    redirect_to combined_course_summary_assessment360_index_path(course_id: params[:course_id])
  end

  # to avoid divide by zero error
  def overall_review_count(assignments, overall_teammate_review_count, overall_meta_review_count)
    assignments.each do |assignment|
      temp_count = overall_teammate_review_count[assignment.id]
      overall_teammate_review_count[assignment.id] = 1 if temp_count.nil? || temp_count.zero?
      temp_count = overall_meta_review_count[assignment.id]
      overall_meta_review_count[assignment.id] = 1 if temp_count.nil? || temp_count.zero?
    end
  end

  # Calculate the overall average review grade that a student has gotten from their teammate(s) and instructor(s)
  def avg_review_calc_per_student(cp, review_info_per_stu, review)
    # check to see if the student has been given a review
    if review_info_per_stu[1] > 0
      temp_avg_grade = review_info_per_stu[0] * 1.0 / review_info_per_stu[1]
      review[cp.id][:avg_grade_for_assgt] = temp_avg_grade.round.to_s
    end
  end

  # Find the list of all students and assignments pertaining to the course.
  # This data is used to compute the instructor assigned grade and peer review scores.
  # There are many nuances about how to collect these scores. See our design document for more deails
  # http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2018_E1871_Grade_Summary_By_Student
  def course_student_grade_summary
    redirect_to combined_course_summary_assessment360_index_path(course_id: params[:course_id])
  end

  def insure_existence_of(course_participants, course)
    if course_participants.empty?
      flash[:error] = "There is no course participant in course #{course.name}"
      redirect_back fallback_location: root_path
      return true
    end
    false
  end
  
  def assignment_grade_summary(cp, assignment_id, penalties)
    user_id = cp.user_id
    # topic exists if a team signed up for a topic, which can be found via the user and the assignment
    topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
    @topics[cp.id][assignment_id] = SignUpTopic.find_by(id: topic_id)
    # instructor grade is stored in the team model, which is found by finding the user's team for the assignment
    team_id = TeamsUser.team_id(assignment_id, user_id)
    team = Team.find(team_id)
    @assignment_grades[cp.id][assignment_id] = team[:grade_for_submission] ? (team[:grade_for_submission] - penalties[:submission]).round(2) : nil
    return if @assignment_grades[cp.id][assignment_id].nil?

    @final_grades[cp.id] += @assignment_grades[cp.id][assignment_id]
    redirect_to combined_course_summary_assessment360_index_path(course_id: params[:course_id])
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
    # Do not consider reviews that have not been filled out by teammates when calculating averages.
    reviews = reviews.reject { |review| review.average_score == 'N/A' }
    grades = 0
    # Check if they person has gotten any review for the assignment
    if reviews.count > 0
      reviews.each { |review| grades += review.average_score.to_i }
      avg_grades = (grades * 1.0 / reviews.count).round
      hash_per_stu[course_participant.id][assignment.id] = avg_grades.to_s
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
    # We can't use complex eager loading here due to the non-standard associations
    # Get the participant first
    participant = AssignmentParticipant.find_by(user_id: user_id, parent_id: assignment_id)
    return nil unless participant
    
    # Get the assignment with questionnaires
    assignment = participant.assignment
    questions = retrieve_questions(assignment.questionnaires, assignment_id)
    participant_scores(participant, questions)
  end

  def format_topic(topic)
    topic.nil? ? '-' : topic.format_for_display
  end

  def format_score(score)
    score.nil? || score.to_s == 'NaN'  ? '-' : score
  end

  helper_method :format_score
  helper_method :format_topic

  # This method is used to display the combined course summary for all students and assignments.
  # It gathers all the necessary data for the course, including assignments, participants, reviews, and grades.
  # The data is then processed to calculate overall review grades and assignment grades for each participant.
  # Finally, it renders the 'course_summary' view with the collected data.
  def combined_course_summary
    course = Course.find(params[:course_id])
    
    # Get assignments data
    @assignments = course.assignments
                        .includes(:participants)
                        .reject(&:is_calibrated)
                        .reject { |a| a.participants.empty? }
    
    # Get course participants
    @course_participants = course.get_participants.includes(:user)
    return if insure_existence_of(@course_participants, course)
    
    # Initialize hashes for all_students_all_reviews data
    @meta_review = {}
    @teammate_review = {}
    @teamed_count = {}
    
    %w[teammate meta].each do |type|
      instance_variable_set("@overall_#{type}_review_grades", {})
      instance_variable_set("@overall_#{type}_review_count", {})
    end
    
    # Initialize hashes for course_student_grade_summary data
    @topics = {}
    @assignment_grades = {}
    @peer_review_scores = {}
    @final_grades = {}
    
    # Preload teams for all participants
    teams_cache = {}
    teams_users = TeamsUser.where(user_id: @course_participants.map(&:user_id))
                           .includes(:team)
    
    teams_users.each do |tu|
      teams_cache[tu.user_id] = tu.team if tu.team
    end
    
    # Process data for each participant
    @course_participants.each do |cp|
      process_all_reviews_data(cp)
      process_grade_summary_data(cp, teams_cache)
    end
    
    # Calculate overall review counts
    overall_review_count(@assignments, @overall_teammate_review_count, @overall_meta_review_count)
    
    render 'course_summary'
  end

  private
  # This method processes the reviews data for a course participant.
  def process_all_reviews_data(cp)
    %w[teammate meta].each { |type| instance_variable_set("@#{type}_review_info_per_stu", [0, 0]) }
    students_teamed = StudentTask.teamed_students(cp.user)
    @teamed_count[cp.id] = students_teamed[@assignments.first.course_id].try(:size).to_i
    
    @meta_review[cp.id] = {}
    @teammate_review[cp.id] = {}
    
    @assignments.each do |assignment|
      process_assignment_reviews(assignment, cp)
    end
    
    avg_review_calc_per_student(cp, @teammate_review_info_per_stu, @teammate_review)
    avg_review_calc_per_student(cp, @meta_review_info_per_stu, @meta_review)
  end
  # This method processes the grade summary data for a course participant.
  def process_grade_summary_data(cp, teams_cache)
    @topics[cp.id] = {}
    @assignment_grades[cp.id] = {}
    @peer_review_scores[cp.id] = {}
    @final_grades[cp.id] = 0
    
    @assignments.each do |assignment|
      process_assignment_grades(assignment, cp, teams_cache)
    end
  end
  # This method processes the assignment reviews for a course participant.
  def process_assignment_reviews(assignment, cp)
    assignment_participant = assignment.participants.find_by(user_id: cp.user_id)
    return if assignment_participant.nil?

    teammate_reviews = assignment_participant.teammate_reviews
    meta_reviews = assignment_participant.metareviews
    
    calc_overall_review_info(assignment,
                            cp,
                            teammate_reviews,
                            @teammate_review,
                            @overall_teammate_review_grades,
                            @overall_teammate_review_count,
                            @teammate_review_info_per_stu)
    
    calc_overall_review_info(assignment,
                            cp,
                            meta_reviews,
                            @meta_review,
                            @overall_meta_review_grades,
                            @overall_meta_review_count,
                            @meta_review_info_per_stu)
  end
  # This method processes the assignment grades for a course participant.
  def process_assignment_grades(assignment, cp, teams_cache)
    user_id = cp.user_id
    assignment_id = assignment.id
    
    assignment_participant = assignment.participants.find_by(user_id: user_id)
    return if assignment_participant.nil?
    
    team = teams_cache[user_id]
    return if team.nil?

    penalties = calculate_penalty(assignment_participant.id)
    
    topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
    @topics[cp.id][assignment_id] = SignUpTopic.find_by(id: topic_id)
    
    @assignment_grades[cp.id][assignment_id] = if team.grade_for_submission
                                               (team.grade_for_submission - penalties[:submission]).round(2)
                                             end
                                             
    if @assignment_grades[cp.id][assignment_id]
      @final_grades[cp.id] += @assignment_grades[cp.id][assignment_id]
    end
    # Find peer review scores for the assignment
    peer_review_score = find_peer_review_score(user_id, assignment_id)
    return if peer_review_score.nil? || 
              peer_review_score[:review].nil? || 
              peer_review_score[:review][:scores].nil? || 
              peer_review_score[:review][:scores][:avg].nil?

    @peer_review_scores[cp.id][assignment_id] = peer_review_score[:review][:scores][:avg].round(2)
  end
end
