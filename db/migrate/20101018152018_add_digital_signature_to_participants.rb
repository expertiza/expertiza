class AddDigitalSignatureToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :digital_signature, :text
  end

  def self.down
    remove_column :participants, :digital_signature
  end
end
