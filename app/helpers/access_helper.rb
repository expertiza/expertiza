module AccessHelper
  def authorize
    unless all_actions_allowed?
      flash_msg
      redirect_back
    end
  end

  def flash_msg
      if params[:controller] == 'response'
        if params.has_key?(:map_id)
          response_map = ResponseMap.find_by_id(params[:map_id])
          response_locked = (!response_map.nil?) ? response_map.locked : false
          if response_locked
            flash[:error] = "One of your teammates is working on the review. Only one person can work on a review at a time."
          else
            flash[:error] = "This #{params[:controller]} is no longer available!"
          end
        end

        if params.has_key?(:id)
          if params[:action] == 'new'
            flash[:error] = "This review was requested by your teammate and only s/he can begin it."
          end
        end

      else
        if current_role && current_role.name.try(:downcase).start_with?('a', 'e', 'i', 'o', 'u')
          flash[:error] = if params[:action] == 'new'
                            "An #{current_role_name.try(:downcase)} is not allowed to create this/these #{params[:controller]}"
                          else
                            "An #{current_role_name.try(:downcase)} is not allowed to #{params[:action]} this/these #{params[:controller]}"
                          end
        else
          flash[:error] = if params[:action] == 'new'
                            "A #{current_role_name.try(:downcase)} is not allowed to create this/these #{params[:controller]}"
                          else
                            "A #{current_role_name.try(:downcase)} is not allowed to #{params[:action]} this/these #{params[:controller]}"
                          end
        end
      end
    end

  def all_actions_allowed?
    if current_user && current_role.super_admin?
      true
    else
      action_allowed?
    end
  end

  def action_allowed?
    # default action_allowed is nil. So to allow any action, we need to override this in the controller.
  end
end
