class AddIsSubmittedToResponseMaps < ActiveRecord::Migration[4.2][4.2]
  def self.up
    begin
      add_column :response_maps, :isSubmitted, :string, :null => true
    rescue
      put $!
    end
  end

  def self.down
    begin
      remove_column :response_maps, :isSubmitted
    rescue
    end
  end
end
