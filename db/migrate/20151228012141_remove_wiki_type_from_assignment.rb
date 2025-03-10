class RemoveWikiTypeFromAssignment < ActiveRecord::Migration[4.2]
  def self.up
    execute 'alter table assignments drop foreign key `fk_assignments_wiki_types`;'
    remove_column :assignments, :wiki_type_id
    drop_table 'wiki_types'
  end
end
