class MenuUpdateTeamList < ActiveRecord::Migration[4.2]
  def self.up
    item = MenuItem.find_by_label('Create team')
    unless item.nil?
      item.name = 'List teams'
      item.label = 'Add teams to assignment'
      item.save
    end
    Role.rebuild_cache
  end

  def self.down
    item = Menu.find_by_label('Add teams to assignment')
    unless item.nil?
      item.name = 'Create team'
      item.label = 'Create team'
    end
    item.save
    Role.rebuild_cache
  end
end
