class RevisionPlanQuestionnaire < Questionnaire
  # return the team's revision planning questions
  def self.questions(team_id, last_seq)
    revision_plan_questions = Question.where(questionnaire_id: self.id, team_id: team_id)
    revision_plan_header = SectionHeader.find_by(txt: "Revision Planning")
    revision_plan_header ||= SectionHeader.create(txt: "Revision Planning", questionnaire_id: self.id, break_before: 1,
                                                  seq: last_seq + 0.5, team_id: -1)
    revision_plan_questions.unshift(revision_plan_header)
  end
end