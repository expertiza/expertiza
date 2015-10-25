module GradesHelper
  # Render the title
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

  def render_ui(param1,param2)
    render :partial => param1,:locals =>param2
  end

  def has_team_and_metareview?
    if params[:action] == "view"
      @assignment = Assignment.find(params[:id])
      @assignment_id = @assignment.id 
    elsif params[:action] == "view_my_scores"
      @assignment_id = Participant.find(params[:id]).parent_id 
    end
    has_team = @assignment.max_team_size > 1
    has_metareview = DueDate.exists?(assignment_id: @assignment_id, deadline_type_id: 5)
    true_num = 0
    if has_team and has_metareview
      true_num = 2
    elsif has_team or has_metareview
      true_num = 1
    else
      true_num = 0
    end      
    return {has_team: has_team, has_metareview: has_metareview, true_num: true_num}
  end
end
