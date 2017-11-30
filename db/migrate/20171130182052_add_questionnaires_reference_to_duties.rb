class AddQuestionnairesReferenceToDuties < ActiveRecord::Migration
  def change
    add_reference :duties, :questionnaires, index: true
  end
end
