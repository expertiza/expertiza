class AddIsSubmittedToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :isSubmitted, :string, null: true
  rescue StandardError
    put $ERROR_INFO
  end

  def self.down
    remove_column :responses, :isSubmitted
  rescue StandardError
  end
end
