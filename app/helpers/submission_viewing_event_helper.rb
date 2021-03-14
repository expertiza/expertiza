module SubmissionViewingEventHelper

  def getTotalTime(response_map_id, round)

    timeLog = SubmissionViewingEvent.where(map_id: response_map_id, round: round)
    totalTime = 0;

    timeLog.each do |linkTime|
      totalTime = totalTime + linkTime.end_at - linkTime.start_at
    end

    return totalTime

  end

end
