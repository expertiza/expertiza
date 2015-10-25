class PopupController < ApplicationController

  def action_allowed?
    true
  end

  # this can be called from "review_report" by clicking team names from instructor end.
  def team_users_popup
    @sum = 0
    @count = 0
#    @teamid = params[:id]
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @assignment_id = @assignment.id
    @id=params[:assignment_id]
    #  @teamname = Team.find(params[:id]).name
#    @teamusers = TeamsUser.where(team_id: params[:id])

    #id2 seems to be a response_map
    if(params[:id2] == nil)
      #  if(@reviewid == nil)
      @scores = nil
    else
      #get the last response from response_map id
      response = Response.where(map_id:params[:id2]).last
      @reviewid = response.id
      @pid = ResponseMap.find(params[:id2]).reviewer_id
      @reviewer_id = Participant.find(@pid).user_id

      @scores = Answer.where(response_id: @reviewid)

      questionnaire =Response.find(@reviewid).questionnaire_by_answer(@scores.first)

#      @maxscore = questionnaire.max_question_score

#      if(@maxscore == nil)
#        @maxscore = 5
#      end



      if(questionnaire.max_question_score == nil)
        questionnaire.max_question_score = 5
      end

      @total_percentage = response.get_average_score
      @sum = response.get_total_score
      @total_possible = response.get_maximum_score
    end

    #    @review_questionnaire = Questionnaire.find(@assignment.review_questionnaire_id)
    #    @review_questions = @review_questionnaire.questions
    #@maxscore = @review_questionnaire.max_question_score


  end


  def participants_popup

    @sum = 0
    @count = 0
#    @participantid = params[:id]
    @uid = Participant.find(params[:id]).user_id
    @assignment_id =   Participant.find(params[:id]).parent_id
    @user = User.find(@uid)
#    @myuser = @user.id
    @temp = 0;
    @maxscore = 0

    if(params[:id2] == nil)
      @scores = nil
    else
      @reviewid = (Response.find_by_map_id(params[:id2])).id
      @pid = ResponseMap.find(params[:id2]).reviewer_id
      @reviewer_id = Participant.find(@pid).user_id
      #@reviewer_id = ReviewMapping.find(params[:id2]).reviewer_id
      @assignment_id = ResponseMap.find(params[:id2]).reviewed_object_id
      @assignment = Assignment.find(@assignment_id)
      @participant = Participant.where(["id = ? and parent_id = ? ", params[:id],@assignment_id])

      ##3
      @revqids = AssignmentQuestionnaire.where(["assignment_id = ?",@assignment.id])
      @revqids.each do |rqid|
        rtype = Questionnaire.find(rqid.questionnaire_id).type
        if( rtype == 'ReviewQuestionnaire')
          @review_questionnaire_id = rqid.questionnaire_id
        end
      end
      if(@review_questionnaire_id)
        @review_questionnaire = Questionnaire.find(@review_questionnaire_id)
        @maxscore = @review_questionnaire.max_question_score
        @review_questions = @review_questionnaire.questions
      end


      ###



      # @maxscore = Questionnaire.find(@assignment.review_questionnaire_id).max_question_score

      @scores = Answer.where(response_id: @reviewid)
      @scores.each do |s|
        @sum = @sum + s.answer
        @temp = @temp + s.answer
        @count = @count + 1
      end

      @sum1 = (100*@sum.to_f )/(@maxscore.to_f * @count.to_f)
      #    @review_questionnaire = Questionnaire.find(@assignment.review_questionnaire_id)
      #    @review_questions = @review_questionnaire.questions
      #
    end


    #    @maxscore = @review_questionnaire.max_question_score

  end

  def view_review_scores_popup
    @reviewerid = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@reviewerid)

  end

  # this can be called from "review_report" by clicking reviewer names from instructor end.
  def reviewer_details_popup
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    @id=params[:assignment_id]
  end

end
