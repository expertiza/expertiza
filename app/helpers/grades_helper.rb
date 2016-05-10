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
    #elsif params[:action] == "view_my_scores" or params[:action] == 'view_review'
    elsif params[:action] == "view_team" or params[:action] == 'view_review'
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

  def get_css_style_for_hamer_reputation(reputation_value)
    if reputation_value < 0.5 
      css_class = 'c1'
    elsif reputation_value >= 0.5 and reputation_value <= 1 
      css_class = 'c2'
    elsif  reputation_value > 1 and reputation_value <= 1.5 
      css_class = 'c3'
    elsif  reputation_value > 1.5 and reputation_value <= 2   
      css_class = 'c4'
    else
      css_class = 'c5'
    end
    return css_class
  end

  def get_css_style_for_lauw_reputation(reputation_value)
    if reputation_value < 0.2 
      css_class = 'c1'
    elsif reputation_value >= 0.2 and reputation_value <= 0.4 
      css_class = 'c2'
    elsif  reputation_value > 0.4 and reputation_value <= 0.6 
      css_class = 'c3'
    elsif  reputation_value > 0.6 and reputation_value <= 0.8   
      css_class = 'c4'
    else
      css_class = 'c5'
    end
    return css_class
  end
end
