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
     aq = AssignmentQuestionnaire.find_by_user_id_and_assignment_id_and_questionnaire_id(assignment.instructor_id, assignment.id, questionnaire.id)
    
     if aq == nil
       aq = AssignmentQuestionnaire.find_by_user_id_and_assignment_id_and_questionnaire_id(assignment.instructor_id, nil, nil)
     end
     allowed_difference = max_possible_score.to_f * aq.notification_limit / 100      
     if new_score < (existing_score - allowed_difference) or new_score > (existing_score + allowed_difference)
       new_pct = new_score.to_f/max_possible_score
       avg_pct = existing_score.to_f/max_possible_score
       curr_item.notify_on_difference(new_pct,avg_pct,aq.notification_limit)
     end
  end

  def label(object_name, method, label)
    content_tag(:label, h(label), :for => "#{object_name}_#{method}")
  end

  def remove_empty_advice(advices)
    filtered_advices = Array.new
    advices.each { | advice |
      if advice.advice.to_s != ""
        filtered_advices << advice
      end
    }
    filtered_advices
  end

  def get_accordion_title(last_topic, new_topic)
    if last_topic.eql? nil
      #this is the first accordion
      render :partial => "response/accordion", :locals => {:title => new_topic, :is_first => true}
    elsif !new_topic.eql? last_topic
      #render new accordion
      render :partial => "response/accordion", :locals => {:title => new_topic, :is_first => false}
    end
  end

  def construct_table(parameters)
    table_hash = {"table_title" => nil, "table_headers" => nil, "start_table" => false, "start_col" => false, "end_col" => false, "end_table" => false}

    #we need to check if these parameters use tables
    parameters = parameters.last(3)
    if parameters[2].nil?
      return table_hash
    end
    current_ques = parameters[2].split("|")[0]
    total_col_ques = parameters[2].split("|")[1]
    current_col = parameters[2].split("|")[2]
    total_col = parameters[2].split("|")[3]

    #since it's first item in a column we need to start a new column
    if current_ques.to_i == 1
      table_hash["start_col"] = true
      #if it's the first column we need to send the title and headers
      if current_col.to_i == 1
        if parameters[0].length > 0
          table_hash["table_title"] = parameters[0]
        end
        table_hash["start_table"] = true
        if parameters[1].length > 0
          table_hash["table_headers"] = parameters[1]
        end
      end
    end
    #end of column, we need to close column
    if current_ques == total_col_ques
      table_hash["end_col"] = true
      #end of table we need to close table
      if total_col == current_col
        table_hash["end_table"] = true
      end
    end
    table_hash
  end

  def find_question_type(question, ques_type, q_number, is_view, file_url, score_range)
    default_textfield_size = "3"
    default_textarea_size = "40x5"
    default_dropdown = ["Edit Rubric", "No Values"]

    case ques_type.q_type
      when "Checkbox"
        #Parameters
        #section::tableTitle::tableHeader1|tableHeader2::curr_col_ques|total_col_ques|curr_col|max_cols

        #look for table parameters
        table_hash = construct_table(ques_type.parameters.split("::"))

        #check to see if rendering view
        view_output = nil
        if is_view
          view_output = "<img src=\"/images/delete_icon.png\">" + question.txt + "<br/>"
          if @review_scores[q_number].comments == "1"
            view_output = "<img src=\"/images/Check-icon.png\">" + question.txt + "<br/>"
          end
        end

        render :partial => "response/checkbox", :locals => {:ques_num => q_number, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
      when "TextField"
        #Parameters
        #section::size::separator1|separator2::curr_ques|max_ques
        q_parameter =  ques_type.parameters.split("::")

        #look for size parameters
        size = default_textfield_size
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          size = q_parameter[1]
        end

        #look for inline and separator parameters
        separator = nil
        is_first = false
        is_last = false
        if !q_parameter[2].nil?
          separator = q_parameter[2].split("|")[q_parameter[3].split("|")[0].to_i - 1]
          if q_parameter[3].split("|")[0].to_i == 1
            is_first = true
          elsif q_parameter[3].split("|")[0] == q_parameter[3].split("|")[1]
            is_last = true
          end
        end

        #check to see if rendering view
        view_output = nil
        if is_view
          view_output = "No Response"
          if !@review_scores[q_number].comments.nil?
            view_output = @review_scores[q_number].comments
          end
        end

        render :partial => "response/textfield", :locals => {:ques_num => q_number, :field_size => size, :ques_text => question.txt, :separator => separator, :isFirst => is_first, :isLast => is_last, :view => view_output}
      when "TextArea"
        #Parameters
        #section::size::tableTitle::tableHeader1|tableHeader2::curr_col_ques|total_col_ques|curr_col|max_cols
        q_parameter =  ques_type.parameters.split("::")

        #look for size parameters
        size = default_textarea_size
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          size = q_parameter[1]
        end

        #look for table parameters
        table_hash = construct_table(q_parameter)

        #check to see if rendering view
        view_output = nil
        if is_view
          view_output = "No Response"
          if !@review_scores[q_number].comments.nil?
            view_output = @review_scores[q_number].comments
          end
        end

        render :partial => "response/textarea", :locals => {:ques_num => q_number, :area_size => size, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
      when "UploadFile"
        #Parameters
        #section

        #check to see if rendering view
        view_output = nil
        if is_view
          view_output = "File has not been uploaded"
          if !file_url.nil?
            view_output = file_url.to_s
          end
        end

        render :partial => "response/fileUpload", :locals => {:ques_num => q_number, :ques_text => question.txt, :view => view_output}
      when "DropDown"
        #Parameters
        #section::ddValue1|ddValue2::tableTitle::tableHeader1|tableHeader2::curr_col_ques|total_col_ques|curr_col|max_cols
        q_parameter =  ques_type.parameters.split("::")

        #look for dropdown values
        dd_values = default_dropdown
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          dd_values = q_parameter[1].split("|")
        end

        #look for table parameters
        table_hash = construct_table(q_parameter)

        #check to see if rendering view
        view_output = nil
        if is_view
          view_output = "No Response"
          if !@review_scores[q_number].comments.nil?
            view_output = @review_scores[q_number].comments
          end
        end

        render :partial => "response/dropdown", :locals => {:ques_num => q_number, :ques_text => question.txt, :options => dd_values, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
      when "Rating"
        #Parameters
        #section::currQues|2

        q_parameter =  ques_type.parameters.split("::")

        #get current question
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          curr_ques = q_parameter[1].split("|")[0]
        end

        #check to see if rendering view
        view_output = nil
        if curr_ques == "2"
          if is_view
            view_output = "No Response"
            if !@review_scores[q_number].comments.nil?
              view_output = @review_scores[q_number].comments
            end
          end
          render :partial => "response/textarea", :locals => {:ques_num => q_number, :area_size => default_textarea_size, :ques_text => question.txt, :table_title => nil, :table_headers => nil, :start_col => nil, :start_table => nil, :end_col => nil, :end_table => nil, :view => view_output}
        else
          if is_view
            view_output = "No Response"
            if !@review_scores[q_number].comments.nil?
              view_output = @review_scores[q_number].comments
            end
          end
          render :partial => "response/dropdown", :locals => {:ques_num => q_number, :ques_text => question.txt, :options => score_range, :table_title => nil, :table_headers => nil, :start_col => nil, :start_table => nil, :end_col => nil, :end_table => nil, :view => view_output}
        end
      end
  end
end
