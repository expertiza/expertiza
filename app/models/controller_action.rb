class ControllerAction < ActiveRecord::Base
  belongs_to :site_controller
  belongs_to :permission

  validates :name, presence: true
  validates :name, uniqueness: {scope: 'site_controller_id'}

  attr_accessor :controller, :permission, :url, :allowed, :specific_name

  scope :order_by_controller_and_action, -> {
    joins('left outer join site_controllers on site_controller_id = site_controllers.id').
      order('site_controllers.name, name')
  }

  def controller
    @controller ||= SiteController.find(self.site_controller_id)
  end

  def permission
    @permission ||= if self.permission_id
                      Permission.find(self.permission_id)
                    else
                      Permission.new(id: nil,
                                     name: "(default -- #{self.controller.permission.name})")
                    end
    @permission
  end

  def effective_permission_id
    self.permission_id || self.controller.permission_id
  end

  def fullname
    if self.site_controller_id and self.site_controller_id > 0
      "#{self.controller.name}: #{self.name}"
    else
      self.name.to_s
      end
  end

  def url
    @url ||= "/#{self.controller.name}/#{self.name}"
    @url
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
      action.allowed = if action.permission_id
                         if perms.key?(action.permission_id)
                           1
                         else
                           0
                                          end
                       else # Controller's permission
                         if perms.key?(action.controller.permission_id)
                           1
                         else
                           0
                                          end
                       end
    end

    actions
  end

  def self.find_for_permission(p_ids)
    if p_ids.present?
      where(['permission_id in (?)', p_ids]).order('name')
    else
      []
    end
  end
end
