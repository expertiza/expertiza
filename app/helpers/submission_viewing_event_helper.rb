module SubmissionViewingEventHelper

  # Returns number of seconds the review given at response_map_id took during given round
  def getTotalTime(response_map_id, round)
    totalSeconds = 0; # Storage for number of seconds

    # Finds submission_viewing_event rows corresponding to map and round given
    SubmissionViewingEvent.where(map_id: response_map_id, round: round).each do |linkTime|
      totalSeconds = totalSeconds + (linkTime.end_at - linkTime.start_at).to_i # accumulates total time for review
    end

    return totalSeconds

  end

  # Returns time in readable text (i.e. 1 hr 2 min 3 sec) given number of seconds
  def secondsToHuman(timeInSec)

    # Calculates number of hours and subtracts
    hours = timeInSec/3600
    timeInSec = timeInSec%3600

    # Calculates number of minutes and subtracts
    mins = timeInSec/60
    timeInSec = timeInSec%60
    # timeInSec now holds remaining seconds

    # Returns string of readable text
    return  "#{hours} hr #{mins} min #{timeInSec} sec"
  end

  # Returns average time taken for a review of an assignment for a specific round given a response_map_id in that assignment and a round
  def getAvgRevTime(response_map_id, round)
    classTimes = [] # holds total review times for each reviewer

    # Gets the assignmentId for the given response_map
    assignmentId = ResponseMap.find(params[:reponse_map_id]).reviewed_object_id

    # Iterates through the ResponseMap table to get maps pertaining to particular assignment
    ResponseMap.where(reviewed_object_id: assignmentId).each do |map|
      classTimes.push(getTotalTime(map.id, params[:round])) # pushes summed review time onto array
    end

    return classTimes.reduce(:+).to_f / classTimes.size # returns average of classTimes array
  end
end
