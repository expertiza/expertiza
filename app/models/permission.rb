class Permission < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  # Find Permissions for a Role ID or an array of Role IDs.

  def Permission.find_for_role(role_ids)
    return find_by_sql( ["select permissions.* from permissions inner join roles_permissions on permissions.id = roles_permissions.permission_id where role_id in (?) order by permissions.name", role_ids] )
  end
  

  # Find all Permissions for a Role.  This method gets the hierarchy
  # for the given Role and uses that to get all the Permissions for
  # the Role and its ancestors.

  def Permission.find_all_for_role(role)
    roles = Role.hierarchy(role.id)
    return find_for_role(roles)
  end


  # Find Permissions that are not already associated with the given
  # Role ID.

  def Permission.find_not_for_role(role_id)
    return find_by_sql( ["select * from permissions where id not in (select permission_id from roles_permissions where role_id in (?)) order by name", role_id] )
  end

end
