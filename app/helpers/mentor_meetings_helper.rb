module MentorMeetingsHelper
  def get_dates_for_team(children)
    team_ids = children.map { |child| child.node_object_id.to_i }
    MentorMeeting.dates_for_teams(team_ids)
  end
end
