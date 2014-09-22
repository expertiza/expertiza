module AccessHelper
  def authorize
    unless all_actions_allowed?
      flash_msg
      redirect_back
    end
  end

  def flash_msg
    flash[:error] = "Permission Denied to #{params[:controller]}##{params[:action]} to role #{current_role_name}"
  end

  def all_actions_allowed?
    if current_user && current_role.super_admin?
      true
    else
      action_allowed?
    end
  end

  def action_allowed?
    #default action_allowed is nil. So to allow any action, we need to override this in the controller.
  end
end
