class ControllerAction < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => 'site_controller_id'

  attr_accessor :controller, :permission, :url, :allowed, :specific_name

  def controller
    @controller ||= SiteController.find(self.site_controller_id)
  end

  def permission
    if not @permission
      if self.permission_id
        @permission = Permission.find_by_id(self.permission_id)
      else
        @permission = Permission.new(:id => nil, 
                                     :name => "(default -- #{self.controller.permission.name})")
      end
    end
    return @permission
  end

  def effective_permission_id
    return self.permission_id || self.controller.permission_id
  end

  def fullname
    if self.site_controller_id and self.site_controller_id > 0
      return "#{self.controller.name}: #{self.name}"
    else
      return "#{self.name}"
    end
  end

  def url
    @url ||= "/#{self.controller.name}/#{self.name}"
    return @url
  end

  def self.actions_allowed(permission_ids)
        # Hash for faster & easier lookups
    if permission_ids
      perms = {}
      for id in permission_ids do
        perms[id] = true
      end
    end

    actions = ControllerAction.find(:all)
    for action in actions do
      if action.permission_id
        if perms.has_key?(action.permission_id)
          action.allowed = 1
        else
          action.allowed = 0
        end
      else  # Controller's permission
        if perms.has_key?(action.controller.permission_id)
          action.allowed = 1
        else
          action.allowed = 0
        end
      end
    end

    return actions
  end

  def self.find_for_permission(p_ids)
    if p_ids and p_ids.length > 0
      return find(:all, 
                  :conditions => ['permission_id in (?)', p_ids],
                  :order => 'name')
    else
      return Array.new
    end
  end

end
