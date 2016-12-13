class CreateLocalDB < ActiveRecord::Migration
  def self.up
    create_table :localdb_scores do |t|
      # Note: Table name pluralized by convention.
      t.column :id, :integer  # the course to which this survey pertains.
      t.column :score, :integer # no. of students participating in the survey
      t.column :round, :integer # no. of students participating in the survey
      t.column :type, :string# last reminder date
      t.column :reference_id, :integer # no. of students participating in the survey
  end

  def self.down
    drop_table :localdb_scores
  end
  end
end
