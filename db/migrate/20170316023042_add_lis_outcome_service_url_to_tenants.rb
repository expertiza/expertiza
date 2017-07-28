class AddLisOutcomeServiceUrlToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :lis_outcome_service_url, :text
  end
end
