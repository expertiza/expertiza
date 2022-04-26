class RevisionPlanQuestionnairesController < QuestionnairesController
  def action_allowed?
    case params[:action]
    when 'edit'
      @team_members = Array.new
      # questionnaire = Questionnaire.find(params[:id])

      TeamsUser.where(["team_id = ?", params[:team_id]]).each do |teamuser|
        @team_members.push(teamuser.user_id)
      end

      (user_logged_in? &&
      @team_members.collect { |u| u.id }.include?(session[:user].id)) || super
    else
      super
    end
  end

  def new
    begin
      questionnaire = RevisionPlanQuestionnaire.get_questionnaire_for_current_round(params[:team_id])
      redirect_to action: 'edit', id: questionnaire.id
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end
end
