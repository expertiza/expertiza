class ResponseMapsToResponse < ActiveRecord::Migration
  def self.up

    change_table :responses do |t|
      t.column :reviewed_object_id, :integer, :null => false
      t.column :reviewer_id, :integer
      t.column :reviewee_id, :integer, :null => false
      t.column :type, :string, :null => false
      t.column :notification_accepted, :boolean, :default => false
    end

    update <<-SQL
      UPDATE responses AS r
      INNER JOIN response_maps AS m ON r.map_id = m.id
      SET r.reviewed_object_id = m.reviewed_object_id,
          r.reviewer_id = m.reviewer_id,
          r.reviewee_id = m.reviewee_id,
          r.type = m.type,
          r.notification_accepted = m.notification_accepted
    SQL

    # Andrew asked to remove the foreign key
    #execute <<-SQL
    #  ALTER TABLE `responses`
    #  ADD CONSTRAINT fk_responses_reviewer
    #  FOREIGN KEY (reviewer_id) REFERENCES participants(id)
    #SQL

    execute <<-SQL
      ALTER TABLE `responses`
      DROP FOREIGN KEY fk_response_response_map
    SQL

    execute <<-SQL
      DROP INDEX `fk_response_response_map`
      ON `responses`
    SQL

    drop_table :response_maps

  end

  def self.down
    create_table :response_maps do |t|
      t.column :reviewed_object_id, :integer, :null => false
      t.column :reviewer_id, :integer, :null => false
      t.column :reviewee_id, :integer, :null => false
      t.column :type, :string, :null => false
      t.column :notification_accepted, :boolean, :default => false
    end

    execute <<-SQL
      ALTER TABLE `responses`
      ADD CONSTRAINT fk_response_response_map
      FOREIGN KEY (map_id) REFERENCES response_maps(id)
    SQL

    execute <<-SQL
      ALTER TABLE `response_maps`
      ADD CONSTRAINT fk_response_map_reviewer
      FOREIGN KEY (reviewer_id) REFERENCES participants(id)
    SQL

    # As per Andrew, the Foreign key should have never been added
    #execute <<-SQL
    #  ALTER TABLE `responses`
    #  DROP FOREIGN KEY fk_responses_reviewer
    #SQL

    change_table :responses do |t|
      t.remove :reviewer_id
      t.remove :reviewed_object_id
      t.remove :reviewee_id
      t.remove :type
      t.remove :notification_accepted
    end

  end
end
