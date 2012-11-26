class CreatePenaltiesCalculated < ActiveRecord::Migration
  def self.up
    create_table "penalties_calculated", :force => true do |t|
      t.column "participant_id", :integer
      t.column "deadline_type_id", :integer
      t.column "penalty_points", :integer
    end

    execute "ALTER TABLE penalties_calculated ADD CONSTRAINT `fk_participant_id` FOREIGN KEY (participant_id) REFERENCES users(id);"
    execute "ALTER TABLE penalties_calculated ADD CONSTRAINT `fk_deadline_type_id` FOREIGN KEY (deadline_type_id) REFERENCES deadline_types(id);"

  end

  def self.down
    drop_table "penalties_calculated"
  end
end
