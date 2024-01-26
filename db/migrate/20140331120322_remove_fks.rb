class RemoveFks < ActiveRecord::Migration[4.2]
  def self.up
    execute 'ALTER TABLE response_maps DROP FOREIGN KEY fk_response_map_reviewer'
  end

  def self.down; end
end
