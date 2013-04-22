require 'helpers/analytic/assignment_analytic'
module CourseAnalytic
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

  #===== number of assignment teams ====#
  def num_assignment_team_list
    list = Array.new
    self.assignments.each do |assignment|
      list << assignment.num_teams
    end
    list
  end

  def total_num_assignment_teams
    num_assignment_team_list.inject(:+)
  end

  def average_num_assignment_teams
    total_num_assignment_teams/num_assignments
  end

  def max_num_assignment_teams
    num_assignment_team_list.max
  end

  def min_num_assignment_teams
    num_assignment_team_list.min
  end

  #===== assignment score =====#
  def average_assignment_score
    list = Array.new
    self.assignments.each do |assignment|
      list << assignment.average_team_score
    end
    list.inject(:+).to_f/num_assignments
  end

  def max_assignment_score
    list = Array.new
    self.assignments.each do |assignment|
      list << assignment.max_team_score
    end
    list.max
  end

  def min_assignment_score
    list = Array.new
    self.assignments.each do |assignment|
      list << assignment.min_team_score
    end
    list.min
  end

  #======= reviews =======#
  def num_assignment_review_list
    list = Array.new
    self.assignments.each do |assignment|
      list << assignment.total_num_team_reviews
    end
    list
  end

  def total_num_assignment_reviews
    num_assignment_review_list.inject(:+)
  end

  def average_num_assignment_reviews
    total_num_assignment_reviews.to_f/num_assignments
  end

  def max_num_assignment_reviews
    num_assignment_review_list.max
  end

  def min_num_assignment_reviews
    num_assignment_review_list.min
  end


  private
  def students
    students = Array.new
    self.participants.each do |participant|
      if participant.user.role_id == Role.student.id
        students << participant
      end
    end
    student
  end
end