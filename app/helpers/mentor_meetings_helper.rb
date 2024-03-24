module MentorMeetingsHelper

  def get_dates_for_team(children)
    @meeting_map = {}

    children.each do |child|
      team_id = child.node_object_id.to_i
      @meeting_map[team_id] = MentorMeeting.where(team_id: team_id).pluck(:meeting_date)
    end

    @meeting_map
  end

end
