class UpdateFieldsInSignUpTopics < ActiveRecord::Migration
  def self.up
    remove_column :sign_up_topics, :start_date
    remove_column :sign_up_topics, :due_date
  rescue StandardError
  end

  def self.down; end
end
