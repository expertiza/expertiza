class DowncasePermissions < ActiveRecord::Migration
  def self.up
      permissions = Permission.find(:all)
      permissions.each{
        | permission |
        permission.name = permission.name.downcase
        permission.save
      }
      Role.rebuild_cache
  end

  def self.down
      permissions = Permission.find(:all)
      permissions.each{
        | permission |
        permission.name = permission.name.downcase
        permission.save
      }    
  end
end
