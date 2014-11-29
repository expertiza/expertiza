class ScoresController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper

  def show
    @participant = AssignmentParticipant.find(params[:id])
    @average_score_results = ScoreCache.get_class_scores(@participant.id)

    @statistics = @average_score_results

    @average_reviews = ScoreCache.get_reviews_average(@participant.id)
    @average_metareviews = ScoreCache.get_metareviews_average(@participant.id)

    @my_reviews = ScoreCache.my_reviews(@participant.id)
    @my_metareviews = ScoreCache.my_metareviews(@participant.id)

    return if redirect_when_disallowed
    @assignment = @participant.assignment
    @questions = Hash.new
    questionnaires = @assignment.questionnaires
    questionnaires.each do |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    end

    rmaps = ParticipantReviewResponseMap.where(reviewee_id: @participant.id, reviewed_object_id: @participant.assignment.id)
    rmaps.find_each do |rmap|
      rmap.update_attribute :notification_accepted, true
    end

    rmaps = ParticipantReviewResponseMap.where reviewer_id: @participant.id, reviewed_object_id: @participant.parent_id
    rmaps.find_each do |rmap|
      mmaps = MetareviewResponseMap.where reviewee_id: rmap.reviewer_id, reviewed_object_id: rmap.map_id
      mmaps.find_each do |mmap|
        mmap.update_attribute :notification_accepted, true
      end
    end

    @pscore = @participant.scores(@questions)
    @stage = @participant.assignment.get_current_stage(@participant.topic_id)
    calculate_all_penalties(@assignment.id)
  end

  private

  def action_allowed?
    case params[:action]
    when 'index'
      ['Student',
       'Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
    end
  end

  def calculate_all_penalties(assignment_id)
    @all_penalties = {}
    @assignment = Assignment.find(assignment_id)
    unless @assignment.is_penalty_calculated
      calculate_for_participants = true
    end
    Participant.where(parent_id: assignment_id).find_each do |participant|
      penalties = calculate_penalty(participant.id)
      @total_penalty = 0
      if(penalties[:submission] != 0 || penalties[:review] != 0 || penalties[:meta_review] != 0)
        unless penalties[:submission]
          penalties[:submission] = 0
        end
        unless penalties[:review]
          penalties[:review] = 0
        end
        unless penalties[:meta_review]
          penalties[:meta_review] = 0
        end
        @total_penalty = (penalties[:submission] + penalties[:review] + penalties[:meta_review])
        l_policy = LatePolicy.find(@assignment.late_policy_id)
        if(@total_penalty > l_policy.max_penalty)
          @total_penalty = l_policy.max_penalty
        end
        if calculate_for_participants == true
          penalty_attr1 = {:deadline_type_id => 1,:participant_id => @participant.id, :penalty_points => penalties[:submission]}
          CalculatedPenalty.create(penalty_attr1)

          penalty_attr2 = {:deadline_type_id => 2,:participant_id => @participant.id, :penalty_points => penalties[:review]}
          CalculatedPenalty.create(penalty_attr2)

          penalty_attr3 = {:deadline_type_id => 5,:participant_id => @participant.id, :penalty_points => penalties[:meta_review]}
          CalculatedPenalty.create(penalty_attr3)
        end
      end
      @all_penalties[participant.id] = {}
      @all_penalties[participant.id][:submission] = penalties[:submission]
      @all_penalties[participant.id][:review] = penalties[:review]
      @all_penalties[participant.id][:meta_review] = penalties[:meta_review]
      @all_penalties[participant.id][:total_penalty] = @total_penalty
    end
    unless @assignment.is_penalty_calculated
      @assignment.update_attribute(:is_penalty_calculated, true)
    end
  end
end
