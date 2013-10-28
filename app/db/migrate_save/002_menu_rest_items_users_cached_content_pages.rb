class MenuRestItemsUsersCachedContentPages < ActiveRecord::Migration
  def self.up
    # Add URL to use for Actions, to better support REST
    add_column 'controller_actions', 'url_to_use', :string

    # Enhancements for Users
    add_column 'users', 'password_salt', :string
    add_column 'users', 'fullname', :string
    add_column 'users', 'email', :string

    # Add caching for ContentPages
    add_column 'content_pages', 'content_cache', :text
  end

  def self.down
    remove_column 'content_pages', 'content_cache'

    remove_column 'users', 'email'
    remove_column 'users', 'fullname'
    remove_column 'users', 'password_salt'

    remove_column 'controller_actions', 'url_to_use'
  end
end
