class AddInstructionLocToQuestionnaire < ActiveRecord::Migration[4.2]
  def self.up
    add_column :questionnaires, :instruction_loc, :text
  end

  def self.down
    remove_column :questionnaires, :instruction_loc
  end
end
