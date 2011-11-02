module ResponseHelper

  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def self.compare_scores(new_response, questionnaire,host)
    map_class = new_response.map.class
    existing_responses = map_class.get_assessments_for(new_response.map.reviewee)
    total, count = get_total_scores(existing_responses,new_response)     
    if count > 0
      notify_instructor(new_response.map.assignment, new_response, questionnaire, total, count,host)
    end
  end   
  
  # Compute the scores previously awarded to the recipient
  # ajbudlon, nov 18, 2008
  def self.get_total_scores(item_list,curr_item)
    total = 0
    count = 0
    item_list.each {
      | item | 
      if item.id != curr_item.id
        count += 1        
        total += item.get_total_score                
      end
    } 
    return total,count
  end
  
  # determine if the instructor should be notified
  # ajbudlon, nov 18, 2008
  def self.notify_instructor(assignment,curr_item,questionnaire,total,count,host)
     max_possible_score, weights = assignment.get_max_score_possible(questionnaire)
     new_score = curr_item.get_total_score.to_f*weights            
     existing_score = (total.to_f/count).to_f*weights 
     aq = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(assignment.instructor_id, assignment.id, questionnaire.id)
    
     if aq == nil
       aq = AssignmentQuestionnaires.find_by_user_id_and_assignment_id_and_questionnaire_id(assignment.instructor_id, nil, nil)
     end
     allowed_difference = max_possible_score.to_f * aq.notification_limit / 100      
     if new_score < (existing_score - allowed_difference) or new_score > (existing_score + allowed_difference)
       new_pct = new_score.to_f/max_possible_score
       avg_pct = existing_score.to_f/max_possible_score

       curr_item.notify_on_difference(new_pct,avg_pct,aq.notification_limit,host)
     end    
  end  
  
end
