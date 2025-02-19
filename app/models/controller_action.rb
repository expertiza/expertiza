class ControllerAction < ApplicationRecord
  belongs_to :site_controller
  belongs_to :permission

  validates :name, presence: true
  validates :name, uniqueness: { scope: 'site_controller_id' }

  # rubocop:disable Lint/DuplicateMethods
  attr_accessor :controller, :permission, :url, :allowed, :specific_name

  scope :order_by_controller_and_action, lambda {
    joins('left outer join site_controllers on site_controller_id = site_controllers.id')
      .order('site_controllers.name, name')
  }

  def controller
    @controller ||= SiteController.find(site_controller_id)
  end

  def permission
    @permission ||= if permission_id
                      Permission.find(permission_id)
                    else
                      Permission.new(id: nil,
                                     name: "(default -- #{controller.permission.name})")
                    end
    @permission
  end

  def effective_permission_id
    permission_id || controller.permission_id
  end

  def fullname
    if site_controller_id && (site_controller_id > 0)
      "#{controller.name}: #{name}"
    else
      name.to_s
    end
  end

  def url
    @url ||= "/#{controller.name}/#{name}"
    @url
  end
  # rubocop:enable Lint/DuplicateMethods

  def self.actions_allowed(permission_ids)
    # Hash for faster & easier lookups
    if permission_ids
      perms = {}
      permission_ids.each do |id|
        perms[id] = true
      end
    end

    actions = ControllerAction.all
    actions.each do |action|
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
