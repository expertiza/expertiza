module MentorMeetingsHelper

  # Fetches meeting dates for a collection of teams represented by child objects
  def get_dates_for_team(children)
    # Initialize an empty hash to store team IDs as keys and meeting dates as values
    @meeting_map = {}

    # Iterate through each child object
    children.each do |child|
      # Extract the team ID from the child object (assuming it has a `node_object_id` attribute)
      # and convert it to an integer
      team_id = child.node_object_id.to_i

      # Find all meeting dates for the current team ID
      meeting_dates = MentorMeeting.where(team_id: team_id).pluck(:meeting_date)

      # Store the meeting dates for the current team ID in the hash map
      @meeting_map[team_id] = meeting_dates
    end

    # Return the populated meeting map
    @meeting_map
  end

end
