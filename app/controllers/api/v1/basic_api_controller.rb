module Api::V1
    class BasicApiController <  ActionController::Base
        # protect_from_forgery with: :null_session
         before_action :authenticate

        def action_allowed?
            true
        end
        
        def current_user
            @current_user
        end

        def current_user_id
            if @current_user
                return @current_user.id
            end
            nil
        end

        def current_user_role?
            current_user.role.name
        end
        
        def current_role_name
            current_role.try :name
        end
        
        def current_role
            current_user.try :role
        end

        def self.verify(_args); end

        def authenticate
            if !auth_present?
              render json: {error: "unauthorized"}, status: 401 
            end
            
            begin
                user = User.find(JWT.decode( request.env["HTTP_AUTHORIZATION"].scan(/Bearer (.*)/).flatten.first,
                                        Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' }).first["user"])
            rescue JWT::ExpiredSignature
                render json: {error: "token expired"}, status: 401 
            end
                                        if user
            @current_user ||= user
            end
        end

        def auth_present?
            !!request.env.fetch("HTTP_AUTHORIZATION", "").scan(/Bearer/).flatten.first
        end

        def current_user_id?(user_id)
            current_user.try(:id) == user_id
        end
    end
end