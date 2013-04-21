require 'assignment_analytic'
module CourseAnalytic
  def students
    students = Array.new
    self.participants.each do |participant|
      if participant.user.role_id == Role.student.id
        students << participant
      end
    end
    student
  end

  #====== general statistics ======#
  def num_participants
    self.participants.count
  end

  def num_students
    self.students.count
  end

  def num_assignments
    self.assignments.count
  end

  def num_assignment_teams
    sum = 0
    self.assignments.each do |assignment|
      sum += assignment.num_teams
    end
    sum
  end

  def num_assignment_team_reviews
    sum = 0
    self.assignments.each do |assignment|
      sum += assignment.num_team_reviews
    end
    sum
  end

  def avg_assignment_team_reviews

  end

  def avg_assignment_team_review_score

  end




end