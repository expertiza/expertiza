class UpdateParticipantTypes < ActiveRecord::Migration[4.2]
  def up
    # Drop old foreign key and index if they exist
    execute("ALTER TABLE participants DROP FOREIGN KEY fk_participant_assignments") rescue nil
    execute("ALTER TABLE participants DROP INDEX fk_participant_assignments") rescue nil

    # Only rename if old column exists
    if column_exists?(:participants, :assignment_id)
      rename_column(:participants, :assignment_id, :parent_id)
    end

    # Add type column only if missing
    add_column(:participants, :type, :string) unless column_exists?(:participants, :type)
  end

  def down
    # Reverse safely
    if column_exists?(:participants, :parent_id)
      rename_column(:participants, :parent_id, :assignment_id)
    end

    remove_column(:participants, :type) if column_exists?(:participants, :type)
  end
end
