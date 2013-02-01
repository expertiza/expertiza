class PopupController < ApplicationController
  layout 'standard'
  def team_users_popup
  @maxscore = 0
  @sum = 0  
  @count = 0
  @teamid = params[:id]
  @team = Team.find(params[:id])
  @assignment = Assignment.find(@team.parent_id)
  @assignment_id = @assignment.id
#  @teamname = Team.find(params[:id]).name
  @teamusers = TeamsParticipant.find_all_by_team_id(params[:id])
  
  if(params[:id2] == nil)
#  if(@reviewid == nil)
    @scores = nil
  else
    @reviewid = (Response.find_by_map_id(params[:id2])).id
    @pid = ResponseMap.find(params[:id2]).reviewer_id
    @reviewer_id = Participant.find(@pid).user_id
    
    @scores = Score.find_all_by_response_id(@reviewid)

    ##3
    @revqids = AssignmentQuestionnaire.find(:all, :conditions => ["assignment_id = ?",@assignment.id])
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
    
    if(@maxscore == nil)
      @maxscore = 5
    end
    
    @scores.each do |s|
      @sum = @sum + s.score
      @s = @sum
      @count = @count + 1
    end
    @sum1 = (100*@sum.to_f )/(@maxscore.to_f * @count.to_f)
    
  end
  
#    @review_questionnaire = Questionnaire.find(@assignment.review_questionnaire_id)
#    @review_questions = @review_questionnaire.questions
    #@maxscore = @review_questionnaire.max_question_score
    
  
end


def participants_popup
  
  @sum = 0  
  @count = 0
  @participantid = params[:id]
  @uid = Participant.find(params[:id]).user_id
  @assignment_id =   Participant.find(params[:id]).parent_id
  @user = User.find(@uid)
  @myuser = @user.id
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
    @participant = Participant.find(:first, :conditions => ["id = ? and parent_id = ? ", params[:id],@assignment_id])

    ##3
    @revqids = AssignmentQuestionnaire.find(:all, :conditions => ["assignment_id = ?",@assignment.id])
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
    
    @scores = Score.find_all_by_response_id(@reviewid)
    @scores.each do |s|
      @sum = @sum + s.score
      @temp = @temp + s.score
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
    @reviewid = params[:id]
    @scores = Score.find_all_by_instance_id(@reviewid)
    
    
  end
  
  def reviewer_details_popup
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    
  end

end
