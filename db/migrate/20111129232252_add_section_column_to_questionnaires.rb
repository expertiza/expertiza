class AddSectionColumnToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column "questionnaires","section", :string # custom rubric section
  end

  def self.down
    remove_column "questionnaires","section"
  end
end
