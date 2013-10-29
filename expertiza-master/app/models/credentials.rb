class Credentials
  
  attr_accessor :role_id, :updated_at, :role_ids
  attr_accessor :permission_ids
  attr_accessor :controllers, :actions, :pages

  # Create a new credentials object for the given role
  def initialize(role_id)
    @role_id = role_id

    role = Role.find(@role_id)
    @updated_at = role.updated_at

    @role_ids = role.get_parents.map{|r|r.id}

    permissions = Permission.find_for_role(@role_ids)
    @permission_ids = permissions.map{|p|p.id}

    if @permission_ids.empty?
      @permission_ids << 0
    end

#    actions = ControllerAction.find_by_sql ["select *, (case when permission_id in (?) then 1 else 0 end) as allowed from view_controller_actions", 
#                                           @permission_ids]
    actions = ControllerAction.actions_allowed(@permission_ids)
    @actions = Hash.new
    for a in actions do
      @actions[a.controller.name] ||= Hash.new
      if a.allowed.to_i == 1
        @actions[a.controller.name][a.name] = true
      else
        @actions[a.controller.name][a.name] = false
      end
    end

    controllers = SiteController.find_by_sql ["select *, (case when permission_id in (?) then 1 else 0 end) as allowed from site_controllers", 
                                              @permission_ids]
    @controllers = Hash.new
    for c in controllers do
      if c.allowed.to_i == 1
        @controllers[c.name] = true
      else
        @controllers[c.name] = false
      end
    end

    pages = ContentPage.find_by_sql ["select id, name, permission_id, (case when permission_id in (?) then 1 else 0 end) as allowed from content_pages",
                                     @permission_ids]
    @pages = Hash.new
    for p in pages do
      if p.allowed.to_i == 1
        @pages[p.name] = true
      else
        @pages[p.name] = false
      end
    end
    
  end

end
