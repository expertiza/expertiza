class RegistrationsControllerDecorator
  Lti2Tp::RegistrationsController.class_eval do
    # def action_allowed?
    #   case params[:action]
    #     when 'index', 'create', 'update'
    #       return true
    #   end
    # end
  end
end