class Api::SessionsController <  ApplicationController 

    def create
        puts "--------------------------------------------------------"
        puts params.inspect
        user  = User.where(email: params[:email]).first
        render json: {status: :created}.to_json
    end

    def destroy

    end

end