class RenameQTypeToTypeInQuestionsTable < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :questions, :q_type, :type
  end

  def self.down
    rename_column :questions, :type, :q_type
  end
end
