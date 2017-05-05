class Assessment360Controller < ApplicationController
  # Added the @instructor to display the instrucor name in the home page of the 360 degree assessment

  def action_allowed?
    true
  end

  def index
    @courses = Course.where(instructor_id: session[:user].id)
    @instructor_id = session[:user].id
    @instructor = User.find(@instructor_id)
  end

  def one_course_all_assignments
    @review_types = %w(TeamReviewResponseMap FeedbackResponseMap TeammateReviewResponseMap MetareviewResponseMap)
    @course = Course.find(params[:course_id])
    @assignments = @course.assignments.reject(&:is_calibrated)
  end

  def all_assignments_all_students
    @course = Course.find(params[:course_id])
    @assignments = Assignment.where(course_id: @course)
  end

  def one_assignment_all_students
    @assignment = Assignment.find(params[:assignment_id])
    @participants = @assignment.participants

    @bc = {}
    @participants.each do |participant|
      @questionnaires = @assignment.questionnaires
      bar_1_data = [participant.average_score * 20]
      color_1 = 'c53711'
      min = 0
      max = 100

      GoogleChart::BarChart.new("300x40", " ", :horizontal, false) do |bc|
        bc.data " ", [100], 'ffffff'
        bc.data "Student", bar_1_data, color_1
        bc.axis :x, range: [min, max]
        bc.show_legend = false
        bc.stacked = false
        bc.data_encoding = :extended
        @bc[participant.user.id] = bc.to_url
      end
    end
  end

  # Find the list of all students and assignments pertaining to the course.
  # This data is used to compute the metareview and teammate review scores.
  def all_students_all_reviews
    course = Course.find(params[:course_id])
    @assignments = course.assignments.reject(&:is_calibrated)
    @course_participants = course.get_participants

    @meta_review = {}
    @teammate_review = {}
    @teamed_count = {}

    # for course
    @overall_teammate_review_grades = {}
    @overall_teammate_review_count = {}
    @overall_meta_review_grades = {}
    @overall_meta_review_count = {}

    @assignments.each do |assignment|
      @overall_teammate_review_grades[assignment.id] = 0
      @overall_teammate_review_count[assignment.id] = 0
      @overall_meta_review_grades[assignment.id] = 0
      @overall_meta_review_count[assignment.id] = 0
    end

    @course_participants.each do |cp|
      # for each assignment
      aggregrate_teammate_review_grades_per_stu = 0
      aggregrate_meta_review_grades_per_stu = 0
      teammate_review_count_per_stu = 0
      meta_review_count_per_stu = 0

      students_teamed = StudentTask.teamed_students(cp.user)
      @teamed_count[cp.id] = students_teamed[course.id].try(:size).to_i
      @assignments.each do |assignment|
        @meta_review[cp.id] = {} unless @meta_review.key?(cp.id)
        @teammate_review[cp.id] = {} unless @teammate_review.key?(cp.id)

        assignment_participant = assignment.participants.find_by(user_id: cp.user_id)
        next if assignment_participant.nil?
        teammate_reviews = assignment_participant.teammate_reviews
        meta_reviews = assignment_participant.metareviews

        teammate_review_grades = 0
        if teammate_reviews.count > 0
          teammate_reviews.each {|teammate_review| teammate_review_grades += teammate_review.get_average_score }
          teammate_review_avg_grades = (teammate_review_grades * 1.0 / teammate_reviews.count).round
          @teammate_review[cp.id][assignment.id] = teammate_review_avg_grades.to_s + '%'
        end

        if teammate_review_grades > 0
          # for each assignment
          aggregrate_teammate_review_grades_per_stu += teammate_review_avg_grades
          teammate_review_count_per_stu += 1
        end

        meta_review_grades = 0
        if meta_reviews.count > 0
          meta_reviews.each {|meta_review| meta_review_grades += meta_review.get_average_score }
          meta_review_avg_grades = (meta_review_grades * 1.0 / meta_reviews.count).round
          @meta_review[cp.id][assignment.id] = meta_review_avg_grades.to_s + '%'
        end

        if meta_review_grades > 0
          # for each assignment
          aggregrate_meta_review_grades_per_stu += meta_review_avg_grades
          meta_review_count_per_stu += 1
        end
        # for course
        if teammate_review_avg_grades
          @overall_teammate_review_grades[assignment.id] += teammate_review_avg_grades
          @overall_teammate_review_count[assignment.id] += 1
        end
        if meta_review_avg_grades
          @overall_meta_review_grades[assignment.id] += meta_review_avg_grades
          @overall_meta_review_count[assignment.id] += 1
        end
      end
      if meta_review_count_per_stu > 0
        temp_avg_grade = aggregrate_meta_review_grades_per_stu * 1.0 / meta_review_count_per_stu
        @meta_review[cp.id][:avg_grade_for_assgt] = temp_avg_grade.round.to_s + '%'
      end
      if teammate_review_count_per_stu > 0
        temp_avg_grade = aggregrate_teammate_review_grades_per_stu * 1.0 / teammate_review_count_per_stu
        @teammate_review[cp.id][:avg_grade_for_assgt] = temp_avg_grade.round.to_s + '%'
      end
    end

    # avoid divide by zero error
    @assignments.each do |assignment|
      @overall_teammate_review_count[assignment.id] = 1 if @overall_teammate_review_count[assignment.id].zero?
      @overall_meta_review_count[assignment.id] = 1 if @overall_meta_review_count[assignment.id].zero?
    end
  end

  def one_assignment_one_student
    @assignment = Assignment.find(params[:assignment_id])
    @participant = AssignmentParticipant.find_by_user_id(params[:user_id])
    @questionnaires = @assignment.questionnaires
    bar_1_data = [@participant.average_score]
    bar_2_data = [@assignment.get_average_score]
    color_1 = 'c53711'
    color_2 = '0000ff'
    min = 0
    max = 100

    GoogleChart::BarChart.new("500x100", " ", :horizontal, false) do |bc|
      bc.data " ", [100], 'ffffff'
      bc.data "Student", bar_1_data, color_1
      bc.data "Class Average", bar_2_data, color_2
      bc.axis :x, range: [min, max]
      bc.show_legend = true
      bc.stacked = false
      bc.data_encoding = :extended
      @bc = bc.to_url
    end
  end

  def all_assignments_one_student
  end
end
