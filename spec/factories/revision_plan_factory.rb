# This file defines factory methods that are functionally related
# to the Expertiza revision plan feature. Factories can be used to create
# objects unique to revision plans, including:
#   RevisionPlanQuestionnaire
#   RevisionPlanTeamMap
#
# Note that many of these classes are subclasses specializing
# in revision planning and that the superclasses have a winder purpose.
# Additionally, objects that are not unique to revision planning but
# which show up in the relationships can be found in
# factories.rb.
FactoryBot.define do
    # Revision Plan Questionnaire is the main representation of a  Revision Plan
    # in the Expertiza model. It shares a one-to-one relationship
    # with RevisionPlanTeamMap, and foreign keys
    # to an Questionaire. 
    factory :revision_plan_questionnaire, class: RevisionPlanQuestionnaire do
        name 'Revision Plan Rubric'
        questionnaire_id { Team.first.id || association(:team).id }
        private 0
        min_question_score 0
        max_question_score 1
        type 'RevisionPlanQuestionnaire'
        display_type 'Revision Plan'
        instruction_loc nil
      end

  # Revision Plan Team Map Map is a relationship between a Revision Plan Questionnaire,
  # and a Team a Participant. The reviewer is an
  # individual participant who is taking the quiz, the reviewee is
  # the team that created the quiz questionnaire.
  factory :revision_plan_team_map, class: RevisionPlanTeamMap do
    revision_plan_questionnaire {RevisionPlanQuestionnaire.first || association(:revision_plan_questionnaire) }
    round 2
  end
end
