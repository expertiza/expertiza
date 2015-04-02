class ControllerAction < ActiveRecord::Base
  belongs_to :site_controller
  belongs_to :permission

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => 'site_controller_id'

  attr_accessor :controller, :permission, :url, :allowed, :specific_name

  scope :order_by_controller_and_action, -> {
    joins('left outer join site_controllers on site_controller_id = site_controllers.id').
    order('site_controllers.name, name')
  }
  
  def self.find_all_by_site_controller_id (id)
    ControllerAction.where(site_controller_id: id)
  end

  def self.find_or_create_by_name (params)
    ControllerAction.find_or_create_by(name: params)
  end

  def controller
    @controller ||= SiteController.find(self.site_controller_id)
  end

  def permission
    if not @permission
      if self.permission_id
        @permission = Permission.find(self.permission_id)
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

    actions = ControllerAction.all
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
    if p_ids && p_ids.length > 0
      where(['permission_id in (?)', p_ids]).order('name')
    else
      Array.new
    end
  end

end
