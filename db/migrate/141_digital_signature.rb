class DigitalSignature < ActiveRecord::Migration
  def self.up
    begin
    execute "ALTER TABLE users
              ADD COLUMN digital_certificate VARCHAR(1000)"
    execute "ALTER TABLE participants
              ADD COLUMN time_stamp DATETIME"  
    execute "ALTER TABLE participants
              ADD COLUMN digital_signature LONGTEXT"  
    rescue
      put $!
    end    
  end

  def self.down
      remove_column :users, :digital_certificate
      remove_column :participants, :time_stamp
      remove_column :participants, :digital_signature
  end
end
