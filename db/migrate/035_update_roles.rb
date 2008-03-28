class UpdateRoles < ActiveRecord::Migration
  def self.up

     
     #Retrieve each role, set each name to lower case per EFG.
     student = Role.find_by_name('Student')
     student.name = student.name.downcase
     student.save
     
     instructor = Role.find_by_name('Instructor')
     instructor.name = instructor.name.downcase
     instructor.save
     
     admin = Role.find_by_name('Administrator')
     admin.name = admin.name.downcase
     admin.save
     
     super_admin = Role.find_by_name('Super-Administrator')
     super_admin.name = super_admin.name.downcase
     super_admin.save
     
     #define new role for teaching assistant. TA's should inherit all permissions granted to students     
     ta = Role.create(:name=>"teaching assistant", :parent_id => student.id)
     
     #update instructor to inherit all permissions from TA      
     instructor.parent_id = ta.id
     instructor.save
 
     #Remove old permissions/roles hierarchy
     execute "DELETE from `roles_permissions` where id > 0"
     
     #define new permissions structure
     sadmin_perm = Permission.find_by_name('Administer Goldberg')
     sadmin_perm.name.downcase
     sadmin_perm.save
     
     admin_perm = Permission.find_by_name('Administer PG')
     admin_perm.name = 'administer expertiza'
     admin_perm.save
     
     instr_perm = Permission.create(:name => 'administer courses')
     ta_perm = Permission.find_by_name('Administer assignments')
     ta_perm.name.downcase
     ta_perm.save
     
     st_perm1 = Permission.find_by_name('Do assignments')
     st_perm1.name.downcase
     st_perm1.save
     
     st_perm2 = Permission.find_by_name('Public pages - view')
     st_perm2.name.downcase
     st_perm2.save
          
     st_perm3 = Permission.find_by_name('Public actions - execute')
     st_perm3.name.downcase
     st_perm3.save
                   
     RolesPermission.create(:role_id => super_admin.id, :permission_id => sadmin_perm.id)
     RolesPermission.create(:role_id => admin.id, :permission_id => admin_perm.id)
     RolesPermission.create(:role_id => instructor.id, :permission_id => instr_perm.id)
     RolesPermission.create(:role_id => ta.id, :permission_id => ta_perm.id)
     RolesPermission.create(:role_id => student.id, :permission_id => st_perm1.id)
     RolesPermission.create(:role_id => student.id, :permission_id => st_perm2.id)
     RolesPermission.create(:role_id => student.id, :permission_id => st_perm3.id)
     
     Role.rebuild_cache         
  end

  def self.down
    
    execute "DELETE from `roles` where id > 0;"
    student = Role.create(:name => 'Student', :parent_id => nil)
    instructor = Role.create(:name => 'Instructor',:parent_id => student.id)
    admin = Role.create(:name => 'Administrator',:parent_id => instructor.id)
    sadmin = Role.create(:name => 'Super-Administrator',:parent_id => admin.id)
    
    execute "DELETE from `permissions` where name = 'administer courses';"
    execute "UPDATE `permissions` set name = 'Administer PG' where name = 'administer expertiza';"
    
    execute "DELETE from `roles_permissions` where id > 0;"
    execute "INSERT INTO `roles_permissions` VALUES (6,1,3)"
    execute "INSERT INTO `roles_permissions` VALUES (7,3,2)"
    execute "INSERT INTO `roles_permissions` VALUES (9,1,4)"
    execute "INSERT INTO `roles_permissions` VALUES (10,2,5);"
    execute "INSERT INTO `roles_permissions` VALUES (11,4,6);"
    execute "INSERT INTO `roles_permissions` VALUES (12,4,1);"
    execute "INSERT INTO `roles_permissions` VALUES (14,2,7);"
    execute "INSERT INTO `roles_permissions` VALUES (15,3,7);"
    execute "INSERT INTO `roles_permissions` VALUES (16,4,7);"
    execute "INSERT INTO `roles_permissions` VALUES (17,4,9);"
    execute "INSERT INTO `roles_permissions` VALUES (18,1,8);"

    Role.rebuild_cache
  end
end
