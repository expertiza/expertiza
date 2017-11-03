class RenameQTypeToTypeInQuestionsTable < ActiveRecord::Migration
  def self.up
  	rename_column :questions, :q_type, :type
  end

  def self.down
  	rename_column :questions, :type, :q_type
  end
end
