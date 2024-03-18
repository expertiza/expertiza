class CreateCalculatedPenalties < ActiveRecord::Migration[4.2]
  def self.up
    create_table 'calculated_penalties', force: true do |t|
      t.column 'participant_id', :integer
      t.column 'deadline_type_id', :integer
      t.column 'penalty_points', :integer
    end
  end

  def self.down
    drop_table 'calculated_penalties'
  end
end
