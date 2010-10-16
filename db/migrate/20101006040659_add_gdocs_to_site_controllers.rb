class AddGdocsToSiteControllers < ActiveRecord::Migration
  def self.up
	execute "insert into site_controllers(name,permission_id,builtin) VALUES('google_docs', 4, 0);"
  end

  def self.down
	execute "delete from site_controllers where name = 'google_docs' and permission_id = 4;"
  end
end
