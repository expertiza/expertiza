class AssignmentQuestionnaire < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire
  has_paper_trail

  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user }
end
