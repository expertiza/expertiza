class AddSubmissionModelToQuestionnaire < ActiveRecord::Migration
  def up
    add_reference :questionnaires, :submission_models, index: true
  end

  def down
    remove_reference :questionnaires, :submission_models, index: true
  end
end
