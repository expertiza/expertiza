module SurveyHelper

  def self.get_assigned_surveys(assignment_id)
      assignment = Assignment.find(assignment_id)
      joiners = AssignmentsQuestionnaires.find(:all, :conditions => ["assignment_id = ?", assignment_id])
      assigned_surveys = []
      for joiner in joiners
        assigned_surveys << Rubric.find(joiner.questionnaire_id)
      end
      assigned_surveys
  end
end