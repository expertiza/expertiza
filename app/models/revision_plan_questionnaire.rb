class RevisionPlanQuestionnaire < Questionnaire
  #E2016: return the team's revision planning questions
  def self.questions(questionnaire_id, team_id, last_seq)
    revision_plan_questions = Question.where(questionnaire_id: questionnaire_id, team_id: team_id)
    revision_plan_header = SectionHeader.find_by(txt: "Revision Planning", questionnaire_id: questionnaire_id)
    revision_plan_header ||= SectionHeader.create(txt: "Revision Planning", questionnaire_id: questionnaire_id, break_before: 1,
                                                  seq: last_seq + 0.5, team_id: -1)
    revision_plan_questions.unshift(revision_plan_header)
  end
end
