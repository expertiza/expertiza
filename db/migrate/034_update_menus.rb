class UpdateMenus < ActiveRecord::Migration
  def self.up
    instructor_perm = Permission.find_by_name('Administer Assignments')
    execute "UPDATE `menu_items` set name='List teams', label='Add teams to assignment' where id=28;"
    execute "UPDATE `controller_actions` set permission_id=#{instructor_perm.id}, url_to_use='' where id=15;"
    execute "UPDATE `content_pages` set permission_id=#{instructor_perm.id} where id=8;"
    execute "UPDATE `content_pages` set permission_id=#{instructor_perm.id} where id=9;" 
    
    execute "UPDATE `site_controllers` set permission_id=7 where id=10;"
    SiteController.create(:name => 'import_file', :permission_id => instructor_perm.id, :builtin => 0)
    SiteController.create(:name => 'course_evaluation', :permission_id => 1, :builtin => 0)
    SiteController.create(:name => 'participant_choices', :permission_id => 1, :builtin => 0)
    
    Role.rebuild_cache
  end

  def self.down
    
    admin_perm = Permission.find_by_name('Administer PG')
    
    execute "UPDATE `menu_items` set name='Create Team', label='Create Team' where id=28;"
    execute "UPDATE `controller_actions` set permission_id=NULL, url_to_use=NULL where id=15;"
    execute "UPDATE `content_pages` set permission_id=#{admin_perm.id} where id=8;"
    execute "UPDATE `content_pages` set permission_id=#{admin_perm.id} where id=9;"
    execute "UPDATE `site_controllers` set permission_id=1 where id=10;"
    execute "DELETE from `site_controllers` where name = 'import_file';"
    execute "DELETE from `site_controllers` where name = 'course_evaluation';"
    execute "DELETE from `site_controllers` where name = 'participant_choices';"
    
    Role.rebuild_cache
  end
end
