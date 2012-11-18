module GradesHelper

  # Render the accordian title
  def get_accordion_title(last_topic, new_topic)
    if last_topic.eql? nil
      #this is the first accordion
      render :partial => "response/accordion", :locals => {:title => new_topic, :is_first => true}

    elsif !new_topic.eql? last_topic
      #render new accordion
      render :partial => "response/accordion", :locals => {:title => new_topic, :is_first => false}

    end
  end

  # Render the table to display the question, score and response
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

  # Render the question, score and response and set default parameters
  def find_question_type(question, ques_type, q_number, is_view, file_url, score, score_range)
    default_textfield_size = "3"
    default_textarea_size = "40x5"
    default_dropdown = ["Edit Rubric", "No Values"]

    #refactored code
    q_parameter =  ques_type.parameters.split("::")
    table_hash = construct_table(q_parameter)
    view_output = nil
    if is_view
      view_output = "No Response"
      if !score.comments.nil?
        view_output = score.comments
      end
    end


    # Render appropriate control for each question type
    case ques_type.q_type
      when "Checkbox"
        if is_view
          view_output = "<img src=\"/images/delete_icon.png\">" + question.txt + "<br/>"
          if score.comments == "1"
            view_output = "<img src=\"/images/Check-icon.png\">" + question.txt + "<br/>"
          end
        end
        param1 = "response/checkbox"
        param2 = {:ques_num => q_number, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
        render_ui(param1,param2)
      when "TextField"

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
        param1 = "response/textfield"
        param2 = {:ques_num => q_number, :field_size => size, :ques_text => question.txt, :separator => separator, :isFirst => is_first, :isLast => is_last, :view => view_output}
        render_ui(param1,param2)
      when "TextArea"

        #look for size parameters
        size = default_textarea_size
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          size = q_parameter[1]
        end

        param1 = "response/textarea"
        param2 = {:ques_num => q_number, :area_size => size, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
        render_ui(param1,param2)
        
      when "UploadFile"

        #check to see if rendering view
        if is_view
          view_output = "File has not been uploaded"
          if !file_url.nil?
            view_output = file_url.to_s
          end
        end
        param1 = "response/fileUpload"
        param2 =  {:ques_num => q_number, :ques_text => question.txt, :view => view_output}
        render_ui(param1,param2)
      when "DropDown"

        #look for dropdown values
        dd_values = default_dropdown
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          dd_values = q_parameter[1].split("|")
        end
        param1 = "response/dropdown"
        param2 = {:ques_num => q_number, :ques_text => question.txt, :options => dd_values, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
        render_ui(param1,param2)
      when "Rating"
        if !q_parameter[1].nil? && q_parameter[1].length > 0
          curr_ques = q_parameter[1].split("|")[0]
        end

        if curr_ques == 2
          param1 = "response/textarea"
          param2 = {:ques_num => q_number, :area_size => default_textarea_size, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}

        else
          param1 = "response/dropdown"
          param2 =  {:ques_num => q_number, :ques_text => question.txt, :options => score_range, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}

        end
        render_ui(param1,param2)
      end
  end
  def render_ui(param1,param2)
    render :partial => param1,:locals =>param2
  end

end
