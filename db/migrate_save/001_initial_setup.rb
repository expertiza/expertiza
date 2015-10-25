class InitialSetup < ActiveRecord::Migration
  def self.up

    create_table 'markup_styles', :force => false do |t|
      t.column 'name', :string, :default => '', :null => false
    end


    create_table 'permissions', :force => false do |t|
      t.column 'name', :string, :default => '', :null => false
    end


    create_table 'site_controllers', :force => false do |t|
      t.column 'name', :string, :default => '', :null => false
      t.column 'permission_id', :integer, :default => 0, :null => false
      t.column 'builtin', :integer, :default => 0
    end

    add_index 'site_controllers', ['permission_id'], :name => 'fk_site_controller_permission_id'


    create_table 'content_pages', :force => false do |t|
      t.column 'title', :string
      t.column 'name', :string, :default => '', :null => false
      t.column 'markup_style_id', :integer
      t.column 'content', :text
      t.column 'permission_id', :integer, :default => 0, :null => false
      t.column 'created_at', :timestamp
      t.column 'updated_at', :timestamp
    end

    add_index 'content_pages', ['permission_id'], :name => 'fk_content_page_permission_id'
    add_index 'content_pages', ['markup_style_id'], :name => 'fk_content_page_markup_style_id'


    create_table 'controller_actions', :force => false do |t|
      t.column 'site_controller_id', :integer, :default => 0, :null => false
      t.column 'name', :string, :default => '', :null => false
      t.column 'permission_id', :integer
    end

    add_index 'controller_actions', ['permission_id'], :name => 'fk_controller_action_permission_id'
    add_index 'controller_actions', ['site_controller_id'], :name => 'fk_controller_action_site_controller_id'


    create_table 'menu_items', :force => false do |t|
      t.column 'parent_id', :integer
      t.column 'name', :string, :default => '', :null => false
      t.column 'label', :string, :default => '', :null => false
      t.column 'seq', :integer
      t.column 'controller_action_id', :integer
      t.column 'content_page_id', :integer
    end

    add_index 'menu_items', ['controller_action_id'], :name => 'fk_menu_item_controller_action_id'
    add_index 'menu_items', ['content_page_id'], :name => 'fk_menu_item_content_page_id'
    add_index 'menu_items', ['parent_id'], :name => 'fk_menu_item_parent_id'


    create_table 'roles', :force => false do |t|
      t.column 'name', :string, :default => '', :null => false
      t.column 'parent_id', :integer
      t.column 'description', :string, :limit => 255, :default => '', :null => false
      t.column 'default_page_id', :integer
      t.column 'cache', :text
      t.column 'created_at', :timestamp
      t.column 'updated_at', :timestamp
    end

    add_index 'roles', ['parent_id'], :name => 'fk_role_parent_id'
    add_index 'roles', ['default_page_id'], :name => 'fk_role_default_page_id'


    create_table 'roles_permissions', :force => false do |t|
      t.column 'role_id', :integer, :default => 0, :null => false
      t.column 'permission_id', :integer, :default => 0, :null => false
    end

    add_index 'roles_permissions', ['role_id'], :name => 'fk_roles_permission_role_id'
    add_index 'roles_permissions', ['permission_id'], :name => 'fk_roles_permission_permission_id'


    create_table 'system_settings', :force => false do |t|
      t.column 'site_name', :string, :default => '', :null => false
      t.column 'site_subtitle', :string
      t.column 'footer_message', :string, :default => ''
      t.column 'public_role_id', :integer, :default => 0, :null => false
      t.column 'session_timeout', :integer, :default => 0, :null => false
      t.column 'default_markup_style_id', :integer, :default => 0
      t.column 'site_default_page_id', :integer, :default => 0, :null => false
      t.column 'not_found_page_id', :integer, :default => 0, :null => false
      t.column 'permission_denied_page_id', :integer, :default => 0, :null => false
      t.column 'session_expired_page_id', :integer, :default => 0, :null => false
      t.column 'menu_depth', :integer, :default => 0, :null => false
    end

    add_index 'system_settings', ['public_role_id'], :name => 'fk_system_settings_public_role_id'
    add_index 'system_settings', ['site_default_page_id'], :name => 'fk_system_settings_site_default_page_id'
    add_index 'system_settings', ['not_found_page_id'], :name => 'fk_system_settings_not_found_page_id'
    add_index 'system_settings', ['permission_denied_page_id'], :name => 'fk_system_settings_permission_denied_page_id'
    add_index 'system_settings', ['session_expired_page_id'], :name => 'fk_system_settings_session_expired_page_id'


    create_table 'users', :force => false do |t|
      t.column 'name', :string, :default => '', :null => false
      t.column 'password', :string, :limit => 40, :default => '', :null => false
      t.column 'role_id', :integer, :default => 0, :null => false
    end

    add_index 'users', ['role_id'], :name => 'fk_user_role_id'

  end

  def self.down
    drop_table 'users'
    drop_table 'system_settings'
    drop_table 'roles_permissions'
    drop_table 'roles'
    drop_table 'menu_items'
    drop_table 'controller_actions'
    drop_table 'content_pages'
    drop_table 'site_controllers'
    drop_table 'permissions'
    drop_table 'markup_styles'
  end
end
