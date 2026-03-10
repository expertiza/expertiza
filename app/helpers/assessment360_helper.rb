module Assessment360Helper
  def calculate_final_grade(course_participant)
    return 0 if @final_grades[course_participant.id].nil?
    
    # Calculate weighted average of instructor grades and peer reviews
    instructor_weight = 0.8  # 80% weight for instructor grades
    peer_weight = 0.2       # 20% weight for peer reviews
    
    instructor_grade = @final_grades[course_participant.id]
    
    # Calculate average peer review score across all assignments
    peer_scores = []
    @assignments.each do |assignment|
      score = @peer_review_scores[course_participant.id][assignment.id]
      peer_scores << score if score && score != 'NaN' && score.to_s != 'NaN'
    end
    
    peer_grade = peer_scores.empty? ? 0 : peer_scores.sum / peer_scores.size.to_f
    
    # Calculate final weighted grade
    (instructor_grade * instructor_weight + peer_grade * peer_weight).round(2)
  end
  # Calculate the average peer review score for a specific assignment across all course participants
  def calculate_average_peer_score(assignment)
    scores = []
    @course_participants.each do |cp|
      score = @peer_review_scores.dig(cp.id, assignment.id)
      # Only add score if it's not nil, not 'NaN', and can be converted to float
      if score && score != 'NaN' && score.to_s != 'NaN'
        begin
          float_score = score.to_f
          scores << float_score unless float_score.nan?
        rescue
          next
        end
      end
    end
    return '-' if scores.empty?
    "#{(scores.sum / scores.size).round(2)}"
  end
  # Calculate the average instructor grade for a specific assignment across all course participants
  def calculate_average_instructor_grade(assignment)
    grades = []
    @course_participants.each do |cp|
      grade = @assignment_grades[cp.id][assignment.id]
      grades << grade if grade && grade != 'NaN' && grade.to_s != 'NaN'
    end
    
    return '-' if grades.empty?
    (grades.sum / grades.size.to_f).round(2)
  end
  # Calculate the average grade for a specific student across all assignments
  def calculate_class_average_grade
    return '-' if @final_grades.empty?
    
    total = 0
    count = 0
    
    @final_grades.each do |_, grade|
      if grade && grade != 'NaN' && grade.to_s != 'NaN'
        total += grade
        count += 1
      end
    end
    
    return '-' if count.zero?
    (total / count.to_f).round(2)
  end
  # Calculate the final grade for the entire class based on instructor grades and peer reviews
  def calculate_class_final_grade
    total = 0
    count = 0
    
    @course_participants.each do |cp|
      grade = calculate_final_grade(cp)
      if grade && grade != 'NaN' && grade.to_s != 'NaN'
        total += grade
        count += 1
      end
    end
    
    return '-' if count.zero?
    (total / count.to_f).round(2)
  end
  # Calculate the average peer review score for the entire class across all assignments
  def calculate_class_peer_average
    scores = []
    @course_participants.each do |cp|
      @assignments.each do |assignment|
        score = @peer_review_scores.dig(cp.id, assignment.id)
        if score && score != 'NaN' && score.to_s != 'NaN'
          begin
            float_score = score.to_f
            scores << float_score unless float_score.nan?
          rescue
            next
          end
        end
      end
    end
    
    return '-' if scores.empty?
    "#{(scores.sum / scores.size).round(2)}"
  end
  # Calculate the average peer review score for a specific student across all assignments
  def calculate_student_peer_average(student)
    scores = []
    @assignments.each do |assignment|
      score = @peer_review_scores.dig(student.id, assignment.id)
      if score && score != 'NaN' && score.to_s != 'NaN'
        begin
          float_score = score.to_f
          scores << float_score unless float_score.nan?
        rescue
          next
        end
      end
    end
    
    return '-' if scores.empty?
    "#{(scores.sum / scores.size).round(2)}"
  end
  # Safely convert a score to float, returning nil for invalid scores
  def safe_score_to_f(score)
    return nil if score.nil? || score == 'NaN' || score.to_s == 'NaN'
    begin
      float_score = score.to_f
      float_score.nan? ? nil : float_score
    rescue
      nil
    end
  end
end 