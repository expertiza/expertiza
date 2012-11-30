class CreateInteractionAdvices < ActiveRecord::Migration
 def self.up
    create_table :interaction_advices do |t|
      t.column "score", :integer
      t.column "advice", :text
      t.column "assignment_id", :integer

    end

    add_index "interaction_advices", ["assignment_id"], :name => "fk_assignments_advices"

    execute "alter table interaction_advices
               add constraint fk_assignments_advices
               foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :interaction_advices
  end
end
