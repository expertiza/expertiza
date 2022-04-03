class VersionTableSupportUtf8 < ActiveRecord::Migration[4.2]
  def change
    execute 'ALTER TABLE versions CONVERT TO CHARACTER SET utf8'
  end
end
