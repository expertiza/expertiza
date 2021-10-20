class DigitalSignature < ActiveRecord::Migration
  def self.up
    add_column :users, :digital_certificate, :text
    add_column :participants, :time_stamp, :datetime
    add_column :participants, :digital_signature, :text
  end

  def self.down
    remove_column :users, :digital_certificate
    remove_column :participants, :time_stamp
    remove_column :participants, :digital_signature
  end
end
