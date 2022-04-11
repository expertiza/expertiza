class AddPotentialResponseDeadlineToResponseMaps < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_maps, :potential_response_deadline, :datetime, null: true
  end

  def self.down
    remove_column :response_maps, :potential_response_deadline
  end
end
