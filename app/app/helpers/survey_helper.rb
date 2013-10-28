module SurveyHelper

  def self.get_assigned_surveys(assignment_id)
      joiners = AssignmentQuestionnaire.find(:all, :conditions => ["assignment_id = ?", assignment_id])
      assigned_surveys = []
      for joiner in joiners
        survey = Questionnaire.find(joiner.questionnaire_id)
        assigned_surveys << survey if survey.type == 'SurveyQuestionnaire'
      end
      assigned_surveys.sort!{|a,b| a.name <=> b.name} 
    end

  def self.get_global_surveys
      global_surveys = Questionnaire.find(:all, :conditions => ["type = ? and private = ?", 'GlobalSurveyQuestionnaire', false])
      global_surveys.sort!{|a,b| a.name <=> b.name} 
   end

  def self.get_all_available_surveys(assignment_id, role_id)
    surveys = SurveyHelper::get_assigned_surveys(assignment_id) 
    surveys += SurveyHelper::get_global_surveys unless role_id == 2
    surveys.sort!{|a,b| a.name <=> b.name}
  end
end