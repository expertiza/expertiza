module ResponseHelper

  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def self.compare_scores(new_response, questionnaire) 
    map_class = new_response.map.class
    existing_responses = map_class.get_assessments_for(new_response.map.reviewee)
    total, count = get_total_scores(existing_responses,new_response)     
    if count > 0
      notify_instructor(new_response.map.assignment, new_response, questionnaire, total, count)
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
  def self.notify_instructor(assignment,curr_item,questionnaire,total,count)
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
       curr_item.notify_on_difference(new_pct,avg_pct,aq.notification_limit)
     end
  end

  def self.label(object_name, method, label)
    content_tag(:label, h(label), :for => "#{object_name}_#{method}")
  end

  def self.get_accordion_title(last_topic, new_topic)
    if last_topic.eql? nil
      #this is the first accordion
      render :partial => "accordion", :locals => {:title => new_topic, :is_first => true}
    elsif !new_topic.eql? last_topic
      #render new accordion
      render :partial => "accordion", :locals => {:title => new_topic, :is_first => false}
    end
  end

  def update_question_count(q_num, question_type)
    if question_type.q_type.eql? "Rating"
      para_array = question_type.parameter.split("::")
      if para_array[2].length > 0
        q_num += 3
      else
        q_num += 2
      end
    else
      q_num += 1
    end
  end

  def self.find_question_type(question, q_type, q_number)
    default_checkbox = ""
    default_textfield = "3"
    default_textarea = "40x5"
    default_textfield_inline = "3"

    case q_type.type
      when "Checkbox"
        q_parameter = default_checkbox
        if !q_type.parameter.nil?
          q_parameter = q_type.parameter
        end
        render :partial => "checkbox", :locals => {:ques_num => q_number, :ques_text => question.txt}
      when "Text Field"
        q_parameter = default_textfield
        if !q_type.parameter.nil?
          q_parameter = q_type.parameter
        end
        render :partial => "textfield", :locals => {:ques_num => q_number, :field_size => q_parameter, :ques_text => question.txt}
      when "Text Area"
        q_parameter = default_textarea
        if !q_type.parameter.nil?
          q_parameter = q_type.parameter
        end
        render :partial => "textarea", :locals => {:ques_num => q_number, :area_size => q_parameter, :ques_text => question.txt}
      when "Text Field Inline"
        q_parameter = default_textfield_inline
        if !q_type.parameter.nil?
          q_parameter = q_type.parameter
        end
        render :partial => "textfield_inline", :locals => {:ques_num => q_number, :field_size => q_parameter}
      when "Rating"
        if !q_type.parameter.nil?
          para_array = q_type.parameter.split("::")

          size = para_array[1]
          dd2 = para_array[3]
          dd2_array = dd2.split("|")
          dd2_title = dd2_array[0]
          dd2_values = Array.new
          for y in 1..dd2_array.length
              dd2_values << dd2_array[y]
          end
          #check if there is a drop down one present
          if para_array[2].length > 0
            dd1 = para_array[2]
            dd1_array = dd1.split("|")
            dd1_title = dd1_array[0]
            dd1_values = Array.new
            #add all selections to the dropdown
            for y in 1..dd1_array.length
              dd1_values << dd1_array[y]
            end
            render :partial => "rating", :locals => {:ques_num => q_number, :size => size, :dropdown1_title => dd1_title, :selections => dd1_values, :dropdown2_title => dd2_title, :grades => dd2_values}
          else
            render :partial => "rating", :locals => {:ques_num => q_number, :size => size, :dropdown1_title => nil, :dropdown2_title => dd2_title, :grades => dd2_values}
          end
        else
          dd2_values = ["Value1", "Value2"]
          render :partial => "rating", :locals => {:ques_num => q_number, :size => "60x5", :dropdown1_title => nil, :dropdown2_title => "CheckParameters", :grades => dd2_values}
        end
      end
    end
end