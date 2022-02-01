class AddIsSubmittedToResponses < ActiveRecord::Migration[4.2]
  def self.up
    begin
      add_column :responses, :isSubmitted, :string, :null => true
    rescue
      put $!
    end
  end

  def self.down
    begin
      remove_column :responses, :isSubmitted
    rescue
    end
  end
end