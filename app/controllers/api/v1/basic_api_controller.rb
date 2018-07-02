module Api::V1
    class BasicApiController <  ApplicationController
       protect_from_forgery with: :null_session
        before_action :authenticate

        def current_user
            @current_user
        end

        def authenticate
            if !auth_present?
            render json: {error: "unauthorized"}, status: 401 
            end
            
            user = User.find(JWT.decode( request.env["HTTP_AUTHORIZATION"].scan(/Bearer (.*)/).flatten.first,
                                        Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' }).first["user"])
            if user
            @current_user ||= user
            end
        end

        def auth_present?
            !!request.env.fetch("HTTP_AUTHORIZATION", "").scan(/Bearer/).flatten.first
        end

    end
end