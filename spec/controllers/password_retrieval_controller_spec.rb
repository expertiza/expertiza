describe PasswordRetrievalController do
  describe 'password reset' do
    it 'create new entry in password_resets table' do
      @user = User.new
      @user.email = 'example@example.edu'
      @user.name = 'John Bumgardner'
      @user.username = 'exe'
      @user.save!
      request_params = { user: { email: 'example@example.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.where(user_email: 'example@example.edu')).to exist
    end
    it 'modifies the token in password_resets_table' do
      @user = User.new
      @user.email = 'example@example.edu'
      @user.name = 'John Bumgardner'
      @user.username = 'Shubham'
      @user.save!
      @password_retrival = PasswordReset.new
      @local_token = 'some random string'
      @password_retrival.token = @local_token
      @password_retrival.user_email = 'example@example.edu'
      @password_retrival.save!
      request_params = { user: { email: 'example@example.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.find_by(user_email: 'example@example.edu').token).not_to eq(@local_token)
    end
    it 'if no user no entry is created' do
      @user = User.new
      @user.email = 'aexample@example.edu'
      @user.username = 'Shubham'
      @user.name = 'John Bumgardner'
      @user.save!
      request_params = { user: { email: 'example@example.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.where(user_email: 'example@example.edu')).not_to exist
    end
  end

  describe 'check if token is expired' do
    it 'checks when token is expired' do
      local_token = 'some random string'
      @password_retrival = PasswordReset.new
      @password_retrival.token = Digest::SHA1.hexdigest(local_token)
      @password_retrival.user_email = 'example@example.edu'
      @password_retrival.save!
      request_params = { token: local_token }
      Timecop.freeze(Time.zone.today + 2.days) do
        get :check_reset_url, params: request_params
        expect(response).to render_template 'password_retrieval/forgotten'
      end
    end

    it 'checks when token does not exist' do
      local_token = 'some random strin'
      local_token_sent_as_parameter = 'randome some'
      @password_retrival = PasswordReset.new
      @password_retrival.token = Digest::SHA1.hexdigest(local_token)
      @password_retrival.user_email = 'example@example.edu'
      @password_retrival.save!
      request_params = { token: local_token_sent_as_parameter }
      get :check_reset_url, params: request_params
      expect(response).to render_template 'password_retrieval/forgotten'
    end

    it 'checks when token is not expired' do
      local_token = 'some random string'
      @password_retrival = PasswordReset.new
      @password_retrival.token = Digest::SHA1.hexdigest(local_token)
      @password_retrival.user_email = 'example@example.edu'
      @password_retrival.save!
      request_params = { token: local_token }
      Timecop.freeze(@password_retrival.updated_at + 2.hours) do
        get :check_reset_url, params: request_params
        expect(response).to render_template 'password_retrieval/reset_password'
      end
    end
  end
end
