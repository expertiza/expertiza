class CreateParticipantHostedDocuments < ActiveRecord::Migration
  def self.up
    create_table :participant_hosted_documents do |t|
      t.integer :assignment_participant_id
      t.string :url
      t.string :label
	  t.string :service
	  t.string :document_type

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_hosted_documents
  end
end
