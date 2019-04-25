class Metric < ActiveRecord::Base


  def update_suggestion_chance(suggestion_chance)
    self.suggestion_chance_percentage = suggestion_chance;
    self.save!
  end

  def suggestion_chance_average(assignment)
    # this method will compute the suggestion_chances average for all responses for the particular assignment
    # if no responses exist for particular assignment, return -1 as average suggestion chance
    # make a list of responses for a particular assignment
    responses = []
    response_map_list = ResponseMap.where(reviewed_object_id: assignment)
    response_map_list.each do |rm|
      responses += Response.where(map_id: rm.id)    # get response for
    end
    puts responses #debug print
    #sum up the suggestion chance percentages

    sum = 0
    not_nil_count = 0
    responses.each do |r|
      if !r.suggestion_chance_percentage.nil?
        sum += r.suggestion_chance_percentage
        not_nil_count += 1
      end
    end
    #return average
    if not_nil_count > 0
      return sum / not_nil_count
    end
    return -1
  end

  def get_sentiment_text(avg_sentiment_for_response)
    #convert average into keyword
    (avg_sentiment_for_response < -0.3) ? "Negative":(avg_sentiment_for_response > 0.3)?"Positive":"Neutral"
  end

end
