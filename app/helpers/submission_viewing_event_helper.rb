module SubmissionViewingEventHelper

  # Returns number of seconds the review given at response_map_id took during given round for a given link
  # if link is not specified give total time for all links in review instead of one specific
  def getTotalTime(map_id, round, link = nil)

    # Removes link parameter if not specified
    searchParams = {
        map_id: map_id,
        round: round, link: link
    }.delete_if{ |key, value| value.blank? }

    totalSeconds = 0; # Storage for number of seconds

    # Finds submission_viewing_event rows corresponding to map and round given
      SubmissionViewingEvent.where(searchParams).each do |linkTime|
        totalSeconds = totalSeconds + (linkTime.end_at - linkTime.start_at).to_i # accumulates total time for review
      end

    return totalSeconds

  end

  # Returns time in readable text (i.e. 1 hr 2 min 3 sec) given number of seconds
  def secondsToHuman(timeInSec)
    human = "" # empty string to store return

    # Ensure time is an integer
    intSeconds = timeInSec.to_i

    # Units of time to break timeInSec into
    [[:hr, 3600], [:min, 60]].map{|unit, numSec|
      human = human.concat("#{intSeconds/numSec} #{unit} ") if intSeconds/numSec > 0
      intSeconds = intSeconds%numSec
    }
    human = human.concat("#{intSeconds} sec")

    # Returns string of readable text
    return human
  end

  # Return array of review times based on specific inputs
  def getReviewTimes(map_id, round, link = nil, getAllSubmissions = nil)
    reviewerTimes = [] # holds total review times for each reviewer

    # Generate search hash
    # if link is not specified remove reviewee_id bc you will then be looking for the entire class average time
    searchParams = {
        # Get assignment id for specific response_map
        reviewed_object_id: ResponseMap.find(map_id).reviewed_object_id,
        # Get reviewee id for team being reviewed in respose_map
        reviewee_id: ResponseMap.find(map_id).reviewee_id
    }.delete_if{ |key, value| (getAllSubmissions == 1 || link == nil) && key == :reviewee_id }

    # Iterates through the ResponseMap table to get maps pertaining to particular assignment
    ResponseMap.where(searchParams).each do |map|
      reviewerTimes.push(getTotalTime(map.id, round, link)) # pushes summed review time onto array
    end

    return classTimes.reduce(:+) / classTimes.size # returns average of classTimes array
  end
end
