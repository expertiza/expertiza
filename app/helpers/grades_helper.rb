module GradesHelper
  # Render the title
  def get_accordion_title(last_topic, new_topic)
    if last_topic.eql? nil
      #this is the first accordion
      render partial: "response/accordion", locals: {title: new_topic, is_first: true}

    elsif !new_topic.eql? last_topic
      #render new accordion
      render partial: "response/accordion", locals: {title: new_topic, is_first: false}

    end
  end

  def render_ui(param1,param2)
    render partial: param1, locals: param2
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
    if has_team && has_metareview
      true_num = 2
    elsif has_team || has_metareview
      true_num = 1
    else
      true_num = 0
    end
    return {has_team: has_team, has_metareview: has_metareview, true_num: true_num}
  end
end
