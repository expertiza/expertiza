class CreateCalculatedPenalties < ActiveRecord::Migration
  def self.up
    create_table "calculated_penalties", :force => true do |t|
      t.column "participant_id", :integer
      t.column "deadline_type_id", :integer
      t.column "penalty_points", :integer
    end

    execute "ALTER TABLE calculated_penalties ADD CONSTRAINT `fk_participant_id` FOREIGN KEY (participant_id) REFERENCES participants(id);"
    execute "ALTER TABLE calculated_penalties ADD CONSTRAINT `fk_deadline_type_id` FOREIGN KEY (deadline_type_id) REFERENCES deadline_types(id);"

  end

  def self.down
    drop_table "calculated_penalties"
  end
end
