class CreateInteractionWeights < ActiveRecord::Migration
  def self.up
    create_table :interaction_weights do |t|

      t.column "max_score", :integer
      t.column "weight", :integer
      t.column "assignment_id", :integer

    end

    add_index "interaction_weights", ["assignment_id"], :name => "fk_assignments"

    execute "alter table interaction_weights
               add constraint fk_assignments
               foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :interaction_weights
  end
end
