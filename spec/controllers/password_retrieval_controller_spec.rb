describe PasswordRetrievalController do
  describe 'password reset' do
    it 'create new entry in password_resets table' do
      @user = User.new
      @user.email = 'example@example.edu'
      @user.fullname = 'John Bumgardner'
      @user.name = 'ex'
      @user.save!
      request_params = { user: { email: 'example@example.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.where(user_email: 'example@example.edu')).to exist
    end
    it 'modifies the token in password_resets_table' do
      @user = User.new
      @user.email = 'example@example.edu'
      @user.fullname = 'John Bumgardner'
      @user.name = 'Shubham'
      @user.save!
      @password_retrieval = PasswordReset.new
      @local_token = 'some random string'
      @password_retrieval.token = @local_token
      @password_retrieval.user_email = 'example@example.edu'
      @password_retrieval.save!
      request_params = { user: { email: 'example@example.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.find_by(user_email: 'example@example.edu').token).not_to eq(@local_token)
    end
    it 'if no user no entry is created' do
      @user = User.new
      @user.email = 'aexample@example.edu'
      @user.name = 'Shubham'
      @user.fullname = 'John Bumgardner'
      @user.save!
      request_params = { user: { email: 'example@example.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.where(user_email: 'example@example.edu')).not_to exist
    end
    it 'if user in request param is nil flash error' do
      request_params = { user: { email: nil } }
      post :send_password, params: request_params
      expect(response).to render_template 'password_retrieval/forgotten'
      expect(flash[:error]).to be_present
    end
  end

  describe 'check if token is expired' do
    it 'checks when token is expired' do
      local_token = 'some random string'
      @password_retrieval = PasswordReset.new
      @password_retrieval.token = Digest::SHA1.hexdigest(local_token)
      @password_retrieval.user_email = 'example@example.edu'
      @password_retrieval.save!
      request_params = { token: local_token }
      Timecop.freeze(Time.zone.today + 2.days) do
        get :check_token_validity, params: request_params
        expect(response).to render_template 'password_retrieval/forgotten'
      end
    end

    it 'checks when token does not exist' do
      local_token = 'some random strin'
      local_token_sent_as_parameter = 'randome some'
      @password_retrieval = PasswordReset.new
      @password_retrieval.token = Digest::SHA1.hexdigest(local_token)
      @password_retrieval.user_email = 'example@example.edu'
      @password_retrieval.save!
      request_params = { token: local_token_sent_as_parameter }
      get :check_token_validity, params: request_params
      expect(response).to render_template 'password_retrieval/forgotten'
    end

    it 'checks when token is not expired' do
      local_token = 'some random string'
      @password_retrieval = PasswordReset.new
      @password_retrieval.token = Digest::SHA1.hexdigest(local_token)
      @password_retrieval.user_email = 'example@example.edu'
      @password_retrieval.save!
      request_params = { token: local_token }
      Timecop.freeze(@password_retrieval.updated_at + 2.hours) do
        get :check_token_validity, params: request_params
        expect(response).to render_template 'password_retrieval/reset_password'
      end
    end
  end

  describe 'check if password updated' do
    it 'check if password and repassword do match' do
      @user = User.new
      @user.email = 'example@example.edu'
      @user.fullname = 'John Doe'
      @user.name = 'classman'
      @user.save!
      @password_retrieval = PasswordReset.new
      @password_retrieval.user_email = 'example@example.edu'
      @password_retrieval.save!
      request_params = { reset: { password: 'AAAAAAAAA123!!', repassword: 'AAAAAAAAA123!!', email: 'example@example.edu' } }
      post :update_password, params: request_params
      expect(PasswordReset.where(user_email: 'example@example.edu')).not_to exist
      expect(response).to redirect_to '/'
    end


    it 'checks if password and repassword do not match' do
        @user = User.new
        @user.email = 'example@example.edu'
        @user.fullname = 'John Doe'
        @user.name = 'classman'
        @user.save!
        @password_retrieval = PasswordReset.new
        @password_retrieval.user_email = 'example@example.edu'
        @password_retrieval.save!
        request_params = { reset: { password: 'BAAAAAAAAA123!!', repassword: 'AAAAAAAAA123!!', email: 'example@example.edu' } }
        post :update_password, params: request_params
        expect(PasswordReset.where(user_email: 'example@example.edu')).to exist
        expect(response).to render_template 'password_retrieval/reset_password'
        expect(flash[:error]).to be_present      
    end
  end
end
