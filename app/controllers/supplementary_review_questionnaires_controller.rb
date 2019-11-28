class SupplementaryReviewQuestionnairesController < QuestionnairesController

  def create_supplementary_review_questionnaire
        @participant = AssignmentParticipant.find(params[:id])
        @team = Team.find(@participant.team.id)
        if @team.supplementary_review_questionnaire_id.nil?
          @questionnaire = Questionnaire.create(private: false, name: "supplementary_review_questionnaire_" + @team.id.to_s,
            instructor_id: @team.id, min_question_score: 0, max_question_score: 5, type: "SupplementaryReviewQuestionnaire", display_type: "Review",
            instruction_loc: Questionnaire::DEFAULT_QUESTIONNAIRE_URL)
            
          if @questionnaire.save
            @team.supplementary_review_questionnaire_id = @questionnaire.id
            @team.save
            flash[:success] = 'You have successfully created a rubric!'
          else
            flash[:error] = $ERROR_INFO
          end
        else
          @questionnaire = Questionnaire.find(@team.supplementary_review_questionnaire_id)
        end
        redirect_to controller: 'supplementary_review_questionnaires', action: 'edit', id: @questionnaire.id
    end
    
end