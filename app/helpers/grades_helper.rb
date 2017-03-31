module GradesHelper
  # Render the title
  def get_accordion_title(last_topic, new_topic)
    if last_topic.eql? nil
      # this is the first accordion
      render partial: "response/accordion", locals: {title: new_topic, is_first: true}

    elsif !new_topic.eql? last_topic
      # render new accordion
      render partial: "response/accordion", locals: {title: new_topic, is_first: false}

    end
  end

  def has_team_and_metareview?
    #returns whether a team and metareveiws exist for a given assignment
    if params[:action] == "view"
      @assignment = Assignment.find(params[:id])
      @assignment_id = @assignment.id
    elsif params[:action] == "view_my_scores" or params[:action] == 'view_review'
      @assignment_id = Participant.find(params[:id]).parent_id
    end
    has_team = @assignment.max_team_size > 1
    has_metareview = AssignmentDueDate.exists?(parent_id: @assignment_id, deadline_type_id: 5)
    true_num = 0
    true_num = if has_team && has_metareview
                 2
               elsif has_team || has_metareview
                 1
               else
                 0
               end
    {has_team: has_team, has_metareview: has_metareview, true_num: true_num}
  end

  def participant
    #returns a participant given an id
    @participant = Participant.find(params[:id])
    @participant
  end

  def pscore
    #returns participant scores
    @participant = Participant.find(params[:id])
    @pscore = @participant.scores(@questions)
    @pscore
  end

  def rscore_review
    #returns all reviews for given participant
    @rscore_review = Rscore.new(pscore, :review) if pscore[:review]
    @rscore_review
  end

  def rscore_metareview
    #returns all metareviews for given participant
    @rscore_metareview = Rscore.new(pscore, :metareview) if pscore[:metareview]
    @rscore_metareview
  end

  def rscore_feedback
    #returns all author feedbacks for given participant
    @rscore_feedback = Rscore.new(pscore, :feedback) if pscore[:feedback]
    @rscore_feedback
  end

  def rscore_teammate
    #returns all teammate reviews for given participant
    @rscore_teammate = Rscore.new(pscore, :teammate) if pscore[:teammate]
    @rscore_teammate
  end

  def p_total_score
    #returns grade for given participant
    @participant = Participant.find(params[:id])
    @pscore = @participant.scores(@questions)
    @total_score = @participant.grade ? participant.grade : @pscore[:total_score]
    @total_score
  end

  def p_title
    #returns pertinent title for grades view for given participant
    @participant = Participant.find(params[:id])
    @title = @participant.grade ? 'A score in blue indicates that the value was overwritten by the instructor or teaching assistant.' : nil
    @title
  end

  def get_css_style_for_hamer_reputation(reputation_value)
    #returns a CSS value for formatting

    css_class = if reputation_value < 0.5
                  'c1'
                elsif reputation_value >= 0.5 and reputation_value <= 1
                  'c2'
                elsif reputation_value > 1 and reputation_value <= 1.5
                  'c3'
                elsif reputation_value > 1.5 and reputation_value <= 2
                  'c4'
                else
                  'c5'
                end
    css_class
  end

  def get_css_style_for_lauw_reputation(reputation_value)
    css_class = if reputation_value < 0.2
                  'c1'
                elsif reputation_value >= 0.2 and reputation_value <= 0.4
                  'c2'
                elsif reputation_value > 0.4 and reputation_value <= 0.6
                  'c3'
                elsif reputation_value > 0.6 and reputation_value <= 0.8
                  'c4'
                else
                  'c5'
                end
    css_class
  end
end
