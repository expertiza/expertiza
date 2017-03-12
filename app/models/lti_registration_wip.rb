class LtiRegistrationWip < ActiveRecord::Base
  def self.change_tenant_secret(tenant_id, new_secret)
    tenant = Tenant.find(tenant_id)
    tenant.secret = new_secret
    tenant.save
  end

  def self.get_tenant_credentials(tenant_id)
    tenant = Tenant.find(tenant_id)
    [tenant.tenant_key, tenant.secret]
  end

  def self.change_secret(tenant, tool_proxy_wrapper, tool_proxy_response_wrapper)
    if tool_proxy_wrapper.first_at('security_contract.shared_secret').present?
      final_secret = tool_proxy_wrapper.first_at('security_contract.shared_secret')
    else
      if tool_proxy_wrapper.first_at('security_contract.tp_half_shared_secret').present?
        final_secret = tool_proxy_response_wrapper.first_at('tc_half_shared_secret') \
          + tool_proxy_wrapper.first_at('security_contract.tp_half_shared_secret')
      end
    end
    final_secret
  end

  def self.complete_reregistration(registration_id)
    @registration = Lti2Tp::Registration.find(registration_id)
    tenant_id = @registration.tenant_id
    tenant = Tenant.find(tenant_id)
    tool_proxy_wrapper = JsonWrapper.new(@registration.tool_proxy_json)
    tool_proxy_response_wrapper = JsonWrapper.new(@registration.tool_proxy_response)

    @registration.final_secret = LtiRegistrationWip.change_secret(tenant, tool_proxy_wrapper, tool_proxy_response_wrapper)
    @registration.save!

    tenant.secret = @registration.final_secret
    tenant.save
  end
end
