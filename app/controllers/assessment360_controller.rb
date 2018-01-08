class Assessment360Controller < ApplicationController
  # Added the @instructor to display the instrucor name in the home page of the 360 degree assessment

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
end
