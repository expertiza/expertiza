class AddDutyIdToParticipants < ActiveRecord::Migration
  def change
    add_reference :participants, :duty, index: { name: 'fk_duty_id'}, foreign_key: true
  end
end
