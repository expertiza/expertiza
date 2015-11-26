module ResponseHelper

  # Begin rearranging rubric after number of reviews for a submission cross review_topic_threshold/REARRANGING_FACTOR
  REARRANGING_FACTOR = 3

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
    response_count=Answer.find_by_sql(["SELECT * FROM answers s, responses r, response_maps rm WHERE s.response_id=r.id AND r.map_id= rm.id AND rm.reviewed_object_id=? AND rm.reviewee_id=? AND s.comments != ? AND s.question_id=?", @map.reviewed_object_id, @map.reviewee_id, empty_response_character, question.id]).count
    response_count
  end

  # Calculate response count for checkbox type questions if any one of the checkboxes is checked
  def find_number_of_responses_for_checkbox(checkbox_questions)
    question_ids=Array.new
    checkbox_questions.each { |checkbox_question|
      question_ids<<checkbox_question.id
    }
    response_count=Answer.find_by_sql(["SELECT * FROM answers s, responses r, response_maps rm WHERE s.response_id=r.id AND r.map_id= rm.id AND rm.reviewed_object_id=? AND rm.reviewee_id=? AND s.comments != '0' AND s.question_id IN (?) GROUP BY r.map_id", @map.reviewed_object_id, @map.reviewee_id, question_ids]).count
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
