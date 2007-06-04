class CreateWikiAssignments < ActiveRecord::Migration
  def self.up
    create_table :wiki_assignments do |t|
	t.column :name, :string #Wiki Assignment Type
    end
    wiki_assignment = WikiAssignment.create(:name=>"No")
    wiki_assignment.save
    wiki_assignment = WikiAssignment.create(:name=>"MediaWiki")
    wiki_assignment.save
    wiki_assignment = WikiAssignment.create(:name=>"DocuWiki")
    wiki_assignment.save
  end

  def self.down
    drop_table :wiki_assignments
  end
end
