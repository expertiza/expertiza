class AddSectionColumnToQuestionnaires < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'questionnaires', 'section', :string # custom rubric section
  end

  def self.down
    remove_column 'questionnaires', 'section'
  end
end
