class AddPotentialResponseDeadlineToResponseMaps < ActiveRecord::Migration
  def self.up
    add_column :response_maps, :potential_response_deadline, :datetime, :null => true  
  end

  def self.down
    remove_column :response_maps, :potential_response_deadline
  end
end
