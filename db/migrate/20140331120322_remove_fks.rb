class RemoveFks < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE response_maps DROP FOREIGN KEY fk_response_map_reviewer"
  end

  def self.down
  end
end
