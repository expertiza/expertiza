class AddPenaltyUnitToParticipants < ActiveRecord::Migration[4.2]
  def self.up
    add_column :late_policies, :penalty_unit, :string, null: false
  end

  def self.down; end
end
