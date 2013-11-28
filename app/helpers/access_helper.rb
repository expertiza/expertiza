module AccessHelper
  def auth_check
    unless action_allowed?
      flash_msg
      redirect_back

    end
  end

end

def flash_msg
  flash[:error] = 'permission denied'
  flash.keep
end
def action_allowed?
  false #default action allowed is false. So to allow any action, we need to override this in the controller.
end