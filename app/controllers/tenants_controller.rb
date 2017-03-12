class TenantsController < InheritedResources::Base

  private

    def tenant_params
      params.require(:tenant).permit(:tenant_key, :secret, :tenant_name)
    end
end

