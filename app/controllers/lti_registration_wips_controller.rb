class LtiRegistrationWipsController < InheritedResources::Base
  def index
    action = params[:action]
    registration_id = params[:registration_id]
    registration = Lti2Tp::Registration.find(registration_id)
    @lti_registration_wip = LtiRegistrationWip.new

    # On orig registration, first assume tenant_name == name
    timeref = Time.now.strftime('%I%M.%S')
    @lti_registration_wip.tenant_name = registration.message_type == 'registration' \
            ? "#{registration.tenant_basename}-#{timeref}" : registration.tenant_name

    @lti_registration_wip.registration_id = registration_id
    @lti_registration_wip.registration_return_url = params[:return_url]

    tcp_wrapper = JsonWrapper.new JSON.load(registration.tool_consumer_profile_json)
    @lti_registration_wip.support_email = tcp_wrapper.first_at('product_instance.support.email')
    @lti_registration_wip.product_name = tcp_wrapper.first_at('product_instance.product_info.product_name.default_value')

    @lti_registration_state = 'check_tenant'

    @lti_registration_wip.save

  end

  def show
    @lti_registration_wip = LtiRegistrationWip.find(request.params[:id])
    @registration = Lti2Tp::Registration.find(@lti_registration_wip.registration_id)
    if @registration.message_type == "registration"
      show_registration
    else
      show_reregistration
    end
  end

  def show_registration
    tenant = Tenant.new
    tenant.tenant_name = @lti_registration_wip.tenant_name
    begin
      tenant.save!
    rescue Exception => exc
      (@lti_registration_wip.errors[:tenant_name] << "Institution name is already in database") and return
    end

    disposition = @registration.prepare_tool_proxy('register')
    if @registration.is_status_failure? disposition
      redirect_to_registration(@registration, disposition) and return
    end

    tool_proxy_wrapper = JsonWrapper.new(@registration.tool_proxy_json)
    tool_proxy_response_wrapper = JsonWrapper.new(@registration.tool_proxy_response)

    tenant.tenant_key = tool_proxy_response_wrapper.first_at('tool_proxy_guid')

    @registration.final_secret = LtiRegistrationWip.change_secret(tenant, tool_proxy_wrapper, tool_proxy_response_wrapper)
    tenant.secret = @registration.final_secret
    tenant.save

    @registration.tenant_id = tenant.id
    @registration.save

    redirect_to_registration @registration, disposition
  end

  def show_reregistration
    tenant = Tenant.where(:tenant_key=>@registration.reg_key).first
    disposition = @registration.prepare_tool_proxy('reregister')

    @registration.status = "reregistered"
    @registration.save!

    return_url = @registration.launch_presentation_return_url + disposition

    redirect_to_registration @registration, disposition
  end

  def update
    @lti_registration_wip = LtiRegistrationWip.find(params[:id])
    @lti_registration_wip.tenant_name = params[:lti_registration_wip][:tenant_name]
    @lti_registration_wip.save

    registration = Lti2Tp::Registration.find(@lti_registration_wip.registration_id)
    registration.tenant_name = @lti_registration_wip.tenant_name
    registration.save

    show
  end

  private

  def redirect_to_registration registration, disposition
    redirect_to "#{@lti_registration_wip.registration_return_url}#{disposition}&id=#{registration.id}"
  end
end
