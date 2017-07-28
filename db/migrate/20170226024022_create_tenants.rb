class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :tenant_key
      t.text :secret
      t.string :tenant_name

      t.timestamps null: false
    end
  end
end
