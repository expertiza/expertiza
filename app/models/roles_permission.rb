# == Schema Information
#
# Table name: roles_permissions
#
#  id            :integer          not null, primary key
#  role_id       :integer          default(0), not null
#  permission_id :integer          default(0), not null
#

class RolesPermission < ActiveRecord::Base

  def RolesPermission.find_for_role(role_ids)
    return find_by_sql [%q{
select roles_permissions.*, permissions.name 
from roles_permissions inner join permissions 
  on roles_permissions.permission_id = permissions.id 
where role_id in (?) order by permissions.name
}, role_ids]
  end

end
