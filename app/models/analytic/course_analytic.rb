require 'analytic/assignment_analytic'
module CourseAnalytic
  #====== general statistics ======#
  def num_participants
    self.participants.count
  end

  def num_assignments
    self.assignments.count
  end

  #===== number of assignment teams ====#
  def total_num_assignment_teams
    assignment_team_counts.inject(:+)
  end

  def average_num_assignment_teams
    if num_assignments == 0
      0
    else
      total_num_assignment_teams.to_f / num_assignments
    end
  end

  def max_num_assignment_teams
    assignment_team_counts.max
  end

  def min_num_assignment_teams
    assignment_team_counts.min
  end

  #===== assignment score =====#
  def average_assignment_score
    if num_assignments == 0
      0
    else
      assignment_average_scores.inject(:+).to_f / num_assignments
    end
  end

  def max_assignment_score
    assignment_max_scores.max
  end

  def min_assignment_score
    assignment_min_scores.min
  end

  #======= reviews =======#
  def assignment_review_counts
    list = []
    self.assignments.each do |assignment|
      list << assignment.total_num_team_reviews
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  def total_num_assignment_reviews
    assignment_review_counts.inject(:+)
  end

  def average_num_assignment_reviews
    total_num_assignment_reviews.to_f / num_assignments
  end

  def max_num_assignment_reviews
    assignment_review_counts.max
  end

  def min_num_assignment_reviews
    assignment_review_counts.min
  end

  def assignment_team_counts
    list = []
    self.assignments.each do |assignment|
      list << assignment.num_teams
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  def assignment_average_scores
    list = []
    self.assignments.each do |assignment|
      list << assignment.average_team_score
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  def assignment_max_scores
    list = []
    self.assignments.each do |assignment|
      list << assignment.max_team_score
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  def assignment_min_scores
    list = []
    self.assignments.each do |assignment|
      list << assignment.min_team_score
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  #=============== unused ============#
  # def students
  #  students = Array.new
  #  self.participants.each do |participant|
  #    if participant.user.role_id == Role.student.id
  #      students << participant
  #    end
  #  end
  #  student
  # end
  #
  # def num_students
  #  self.students.count
  # end
end
