<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
module SurveyHelper

  def self.get_assigned_surveys(assignment_id)
      joiners = AssignmentQuestionnaires.find(:all, :conditions => ["assignment_id = ?", assignment_id])
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
<<<<<<< HEAD
=======
=======
module SurveyHelper

  def self.get_assigned_surveys(assignment_id)
      joiners = AssignmentQuestionnaires.find(:all, :conditions => ["assignment_id = ?", assignment_id])
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
module SurveyHelper

  def self.get_assigned_surveys(assignment_id)
      joiners = AssignmentQuestionnaires.find(:all, :conditions => ["assignment_id = ?", assignment_id])
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
end