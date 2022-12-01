class AlterMaxTeamSize
  def self.run!
    improper_assignments = Assignment.all(conditions: 'max_team_size = 0')
    improper_assignments.map do |assignment|
      assignment.max_team_size = 1
      assignment.save(false)
    end
  end
end
