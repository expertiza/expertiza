module ResponseHelper

  # Begin rearranging rubric after number of reviews for a submission cross review_topic_threshold/REARRANGING_FACTOR
  REARRANGING_FACTOR = 3

  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def self.compare_scores(new_response, questionnaire)
    map_class = new_response.map.class
    existing_responses = map_class.get_assessments_for(new_response.map.reviewee)
    total, count = get_total_scores(existing_responses, new_response)
    if count > 0
      notify_instructor(new_response.map.assignment, new_response, questionnaire, total, count)
    end
  end

  # Compute the scores previously awarded to the recipient
  # ajbudlon, nov 18, 2008
  def self.get_total_scores(item_list, curr_item)
    total = 0
    count = 0
    item_list.each {
        |item|
      if item.id != curr_item.id
        count += 1
        total += item.get_total_score
      end
    }
    return total, count
  end

  # determine if the instructor should be notified
  # ajbudlon, nov 18, 2008
  def self.notify_instructor(assignment, curr_item, questionnaire, total, count)
    max_possible_score, weights = assignment.get_max_score_possible(questionnaire)
    new_score = curr_item.get_total_score.to_f*weights
    existing_score = (total.to_f/count).to_f*weights

    aq = AssignmentQuestionnaire.where(user_id: assignment.instructor_id, assignment_id: assignment.id, questionnaire_id: questionnaire.id).first

    unless aq
      aq = AssignmentQuestionnaire.where(user_id: assignment.instructor_id, assignment_id: nil, questionnaire_id: nil).first
    end

    if aq
      allowed_difference = max_possible_score.to_f * aq.notification_limit / 100
      if new_score < (existing_score - allowed_difference) or new_score > (existing_score + allowed_difference)
        new_pct = new_score.to_f/max_possible_score
        avg_pct = existing_score.to_f/max_possible_score
        curr_item.notify_on_difference(new_pct, avg_pct, aq.notification_limit)
      end
    end
  end

  def label(object_name, method, label)
    content_tag(:label, h(label), :for => "#{object_name}_#{method}")
  end

  def remove_empty_advice(advices)
    filtered_advices = Array.new
    advices.each { |advice|
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

  def find_question_type(question, ques_type, q_number, is_view, file_url, score, score_range)
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
          view_output = "<img src=\"/assets/delete_icon.png\">" + question.txt + "<br/>"
          if @review_scores && @review_scores[q_number].comments == "1"
            view_output = "<img src=\"/assets/Check-icon.png\">" + question.txt + "<br/>"
          end
        end

        render :partial => "response/checkbox", :locals => {:ques_num => q_number, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}

      when "TextField"
        #Parameters
        #section::size::separator1|separator2::curr_ques|max_ques
        q_parameter = ques_type.parameters.split("::")

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
          if @review_scores && !@review_scores[q_number].comments.nil?
            view_output = @review_scores[q_number].comments
          end
        end

        render :partial => "response/textfield", :locals => {:ques_num => q_number, :field_size => size, :ques_text => question.txt, :separator => separator, :isFirst => is_first, :isLast => is_last, :view => view_output}

      when "TextArea"
        #Parameters
        #section::size::tableTitle::tableHeader1|tableHeader2::curr_col_ques|total_col_ques|curr_col|max_cols
        q_parameter = ques_type.parameters.split("::")

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
          if @review_scores && !@review_scores[q_number].comments.nil?
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
        q_parameter = ques_type.parameters.split("::")

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

        q_parameter = ques_type.parameters.split("::")

        #get current question
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          curr_ques = q_parameter[1].split("|")[0]
        end

        #check to see if rendering view
        view_output = nil
        if curr_ques == "2"
          if is_view
            view_output = "No Response"
            if @review_scores && !@review_scores[q_number].comments.nil?
              view_output = @review_scores[q_number].comments
            end
          end
          render :partial => "response/textarea", :locals => {:ques_num => q_number, :area_size => default_textarea_size, :ques_text => question.txt, :table_title => nil, :table_headers => nil, :start_col => nil, :start_table => nil, :end_col => nil, :end_table => nil, :view => view_output}
        else
          if is_view
            view_output = "No Response"
            if @review_scores && @review_scores[q_number].try(:comments)
              view_output = @review_scores[q_number].comments
            end
          end
          render :partial => "response/dropdown", :locals => {:ques_num => q_number, :ques_text => question.txt, :options => score_range, :table_title => nil, :table_headers => nil, :start_col => nil, :start_table => nil, :end_col => nil, :end_table => nil, :view => view_output}
        end
    end
  end

  # Rearrange questions shown to a reviewer based on response count
  # for each question and accordion panel of previous reviews for that submission
  def rearrange_questions(questions)
    if (check_threshold)
      return questions
    end

    # Initialize local variables
    panel_questions=Hash.new
    panel_scores=Hash.new
    questions_response_count=Hash.new
    sorted_panel_questions=Array.new
    prev_topic=nil
    current_topic=nil
    primary_response_count=0
    sorted_questions=Array.new
    grouped_questions=Array.new

    # Loop through questions array and store in a hash with its response counts
    questions.each {
        |question|
      question_type=question.question_type
      current_topic = question_type.parameters.split("::")[0]
      grouping_position= question_type.parameters.split("::").length==1 ? nil : question_type.parameters.split("::").last.split("|")[0]
      grouping_count= question_type.parameters.split("::").length==1 ? nil : question_type.parameters.split("::").last.split("|")[1].to_i
      # grouping_position > 1 implies secondary questions among questions grouped by 1|2 logic
      # we need to call to_i method on grouping_position if it is a string
      if grouping_position.to_i<=1
        # create new hash set for new accordion panel
        unless (!current_topic.nil? && (current_topic==prev_topic || prev_topic.nil?))
          panel_score, sorted_panel_questions = process_panel(questions, questions_response_count)
          panel_questions[prev_topic]=sorted_panel_questions
          panel_scores[prev_topic]=panel_score/sorted_panel_questions.length

          questions_response_count=Hash.new
        end
        # calculate response count when first checkbox type question comes
        # for the rest of the checkbox questions; assign the same calculated response count
        if question_type.q_type.eql? 'Checkbox'
          unless (!current_topic.eql? prev_topic)
            checkbox_questions=questions.select { |checkbox_question| checkbox_question.question_type.parameters.split("::")[0].eql?(current_topic) }
            primary_response_count= find_number_of_responses_for_checkbox(checkbox_questions)
          end
        # calculate response count for corresponding comment for Rating type of questions
        elsif (question_type.q_type.eql? 'Rating') && (grouping_position.to_i==1)
          current_question_index=questions.index(question)
          curr_question=questions.fetch(current_question_index+1)
          primary_response_count= find_number_of_responses(curr_question)
        else # ungrouped questions
          primary_response_count= find_number_of_responses(question)
        end
      end
      questions_response_count[question.id]= primary_response_count
      prev_topic=current_topic
    }

    # Ensure last hash of questions is also included in the final rearranged question array
    unless (questions_response_count.empty?)
      panel_score, sorted_panel_questions = process_panel(questions, questions_response_count)
      panel_questions[prev_topic]=sorted_panel_questions
      panel_scores[prev_topic]=panel_score/questions_response_count.length
    end

    # Create final array of rearranged questions by sorting hash of each panel
    panel_scores=Hash[panel_scores.sort_by { |k, v| v }]
    panel_scores.each {
        |key, value|
      panel_questions.fetch(key).each { |question| sorted_questions << question }
    }
    return sorted_questions
  end

  # Sorts panel questions by response count and total panel score
  # returns panel score and array of sorted questions
  def process_panel(questions, questions_response_count)
    questions_response_count=Hash[questions_response_count.sort_by { |k, v| [v, k] }]
    panel_score=0
    sorted_panel_questions=Array.new
    questions_response_count.each {
        |key, value|
      sorted_panel_questions << questions.select { |q| q.id.eql?(key) }[0]
      panel_score+=value
    }
    return panel_score, sorted_panel_questions
  end

  # Calculate response count for a question based on empty_response_character
  def find_number_of_responses(question)
    empty_response_character=''
    case question.question_type.q_type
      when "TextBox", "TextArea", "Rating" # For ratings, we count responses for comments instead of dropdown
        empty_response_character=''
      when "DropDown"
        empty_response_character= @questionnaire.min_question_score
    end
    response_count=Score.find_by_sql(["SELECT * FROM scores s, responses r, response_maps rm WHERE s.response_id=r.id AND r.map_id= rm.id AND rm.reviewed_object_id=? AND rm.reviewee_id=? AND s.comments != ? AND s.question_id=?", @map.reviewed_object_id, @map.reviewee_id, empty_response_character, question.id]).count
    response_count
  end

  # Calculate response count for checkbox type questions if any one of the checkboxes is checked
  def find_number_of_responses_for_checkbox(checkbox_questions)
    question_ids=Array.new
    checkbox_questions.each { |checkbox_question|
      question_ids<<checkbox_question.id
    }
    response_count=Score.find_by_sql(["SELECT * FROM scores s, responses r, response_maps rm WHERE s.response_id=r.id AND r.map_id= rm.id AND rm.reviewed_object_id=? AND rm.reviewee_id=? AND s.comments != '0' AND s.question_id IN (?) GROUP BY r.map_id", @map.reviewed_object_id, @map.reviewee_id, question_ids]).count
    response_count
  end

  # calculates number of reviews received for current submission
  def check_threshold
    max_threshold = @assignment.review_topic_threshold
    #Assignment.find_by_sql(["SELECT review_topic_threshold FROM pg_development.assignments WHERE assignments.id =?",assign.id])
    num_reviews = ResponseMap.find_by_sql(["SELECT * FROM response_maps rm where rm.reviewed_object_id =? AND rm.reviewee_id=?", @assignment.id, @map.reviewee_id]).count
    if max_threshold == 0 || max_threshold.nil?
      max_threshold = 5
    end

    if num_reviews < (max_threshold/REARRANGING_FACTOR)
      return true
    else
      return false
    end

  end
end
