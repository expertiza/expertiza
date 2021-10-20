class VersionTableSupportUtf8 < ActiveRecord::Migration
  def change
    execute "ALTER TABLE versions CONVERT TO CHARACTER SET utf8"
  end
end
