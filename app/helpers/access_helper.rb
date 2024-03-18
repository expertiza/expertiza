module AccessHelper
  def authorize
    unless all_actions_allowed?
      flash_msg
      redirect_back fallback_location: root_path
    end
  end

  def flash_msg
    flash[:error] = if current_role && current_role.name.try(:downcase).start_with?('a', 'e', 'i', 'o', 'u')
                      if params[:action] == 'new'
                        "An #{current_role_name.try(:downcase)} is not allowed to create this/these #{params[:controller]}"
                      else
                        "An #{current_role_name.try(:downcase)} is not allowed to #{params[:action]} this/these #{params[:controller]}"
                      end
                    else
                      if params[:action] == 'new'
                        if current_role_name.nil?
                          "Please complete the CAPTCHA. You are not allowed to create this/these #{params[:controller]}"
                        else
                          "A #{current_role_name.try(:downcase)} is not allowed to create this/these #{params[:controller]}"
                        end
                      else
                        "A #{current_role_name.try(:downcase)} is not allowed to #{params[:action]} this/these #{params[:controller]}"
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
    if current_user && current_role.instructor?
      # allow action when the user is an instructor
      true
    end
  end
end
