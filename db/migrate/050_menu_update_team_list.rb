class MenuUpdateTeamList < ActiveRecord::Migration
  def self.up
    item = MenuItem.find_by_label('Create team')
    if item != nil
      item.name = 'List teams'
      item.label = 'Add teams to assignment'
      item.save
    end
    Role.rebuild_cache
  end

  def self.down
    item = Menu.find_by_label('Add teams to assignment')
    if item != nil
      item.name = 'Create team'
      item.label = 'Create team'
    end
    item.save
    Role.rebuild_cache
  end
end
