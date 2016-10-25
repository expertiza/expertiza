class DropGoldbergTables < ActiveRecord::Migration
  def self.up
    drop_table :goldberg_content_pages
    drop_table :goldberg_controller_actions
    drop_table :goldberg_markup_styles
    drop_table :goldberg_menu_items
    drop_table :goldberg_permissions
    drop_table :goldberg_roles
    drop_table :goldberg_roles_permissions
    drop_table :goldberg_site_controllers
    drop_table :goldberg_system_settings
    drop_table :goldberg_users
  end

  def self.down
  end
end
