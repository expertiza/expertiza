class MentorMeeting < ApplicationRecord
  def self.dates_for_teams(team_ids)
    where(team_id: team_ids).pluck(:team_id, :meeting_date).group_by(&:first).transform_values { |v| v.map(&:last) }
  end
end
