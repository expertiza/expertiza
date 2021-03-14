module SubmissionViewingEventHelper
  def getTotalTime(response_map_id, round)
    timeLog = SubmissionViewingEvent.where(map_id: response_map_id, round: round)

  end
end
