class CreateReviewMappings < ActiveRecord::Migration
  # This table should have essentially the same format as review_of_review_mappings
  def self.up
    create_table :review_mappings do |t|
      t.column :author_id, :integer # if an individual is being reviewed, this field is non-null, otherwise is null
      t.column :team_id, :integer   # if a team is being reviewed, this field is non-null, otherwise is null
      t.column :reviewer_id, :integer
      t.column :assignment_id, :integer  # assignment that is being reviewed
    end
    execute "alter table review_mappings 
          add constraint fk_review_mapping_assignments
          foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :review_mappings
  end
end
