class CreateRoles < ActiveRecord::Migration
  # This table need not be created in migration, as it is already created by Goldberg
  def self.up
    create_table :roles do |t|
      # t.column :name, :string
      t.column :name, :string, :limit=>32
    end
    role = Role.create(:name=>"suadmin")
    role.save
    role = Role.create(:name=>"admin")
    role.save
    role = Role.create(:name=>"instructor")
    role.save
    role = Role.create(:name=>"student")
    role.save
  end
  
  def self.down
    drop_table :roles
  end
end
