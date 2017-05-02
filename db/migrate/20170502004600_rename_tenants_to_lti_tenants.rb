class RenameTenantsToLtiTenants < ActiveRecord::Migration
  def change
    rename_table :tenants, :lti_tenants
  end
end
