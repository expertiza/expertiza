class TeamFormation < DeadlineType
  
  def email_list(assignment_id)
    emails =[]
    assignment = Assignment.find(self.assignment_id)
    if (assignment.team_assignment?)
      emails = get_one_member_team
    end
   emails
end
  def get_one_member_team
    mail_list = []
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    for team_id in teams.keys
      next unless teams[team_id] == 1
      user_id = TeamsUser.where(team_id: team_id).first.user_id
      email = User.find(user_id).email
      mail_list << email
    end
    mail_list
  end
end
