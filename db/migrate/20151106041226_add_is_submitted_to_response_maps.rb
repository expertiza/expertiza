class AddIsSubmittedToResponseMaps < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_maps, :isSubmitted, :string, null: true
  rescue StandardError
    put $ERROR_INFO
  end

  def self.down
    remove_column :response_maps, :isSubmitted
  rescue StandardError
  end
end
