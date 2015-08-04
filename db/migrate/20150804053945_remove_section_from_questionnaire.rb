class RemoveSectionFromQuestionnaire < ActiveRecord::Migration
  def change
    remove_column "questionnaires","section"
  end
end
