describe PasswordRetrievalController do
  describe 'password reset' do
    it 'create new entry in password_resets table' do
      @user = FactoryBot.create(:user)
      @user.save!
      request_params = { user: { email: @user.email } }
      post :send_password, params: request_params
      expect(PasswordReset.where(user_email: @user.email)).to exist
    end
    it 'modifies the token in password_resets_table' do
      @user = FactoryBot.create(:user)
      @user.save!
      @password_retrieval = FactoryBot.build(:password_reset, user_email: @user.email)
      @password_retrieval.save!
      request_params = { user: { email: @user.email } }
      post :send_password, params: request_params
      expect(PasswordReset.find_by(user_email: @password_retrieval.user_email).token).not_to eq(@password_retrieval.token)
    end
    it 'if no user no entry is created' do
      @user = FactoryBot.create(:user)
      @user.save!
      request_params = { user: { email: 'notafactoryboy@ncsu.edu' } }
      post :send_password, params: request_params
      expect(PasswordReset.where(user_email: @user.email)).not_to exist
    end
    it 'if user in request param is nil flash error' do
      request_params = { user: { email: nil } }
      post :send_password, params: request_params
      expect(response).to render_template 'password_retrieval/forgotten'
      expect(flash[:error]).to be_present
    end
    it 'if user in request param is blank flash error' do
      request_params = { user: { email: '' } }
      post :send_password, params: request_params
      expect(response).to render_template 'password_retrieval/forgotten'
      expect(flash[:error]).to be_present
    end
  end

  describe 'check if token is expired' do
    it 'checks when token is expired' do
      non_encrypted_token = 'factory_bot_token'
      @password_retrieval = FactoryBot.build(:password_reset, token: Digest::SHA1.hexdigest(non_encrypted_token))
      @password_retrieval.save!
      request_params = { token: non_encrypted_token }
      Timecop.freeze(Time.zone.today + 2.days) do
        get :check_token_validity, params: request_params
        expect(response).to render_template 'password_retrieval/forgotten'
      end
    end

    it 'checks when token does not exist' do
      non_encrypted_token = 'factory_bot_token'
      @password_retrieval = FactoryBot.build(:password_reset, token: Digest::SHA1.hexdigest(non_encrypted_token))
      @password_retrieval.save!
      request_params = { token: nil }
      get :check_token_validity, params: request_params
      expect(response).to render_template 'password_retrieval/forgotten'
    end

    it 'checks when token is not expired' do
      hours_until_expiration = 2
      non_encrypted_token = 'factory_bot_token'
      @password_retrieval = FactoryBot.build(:password_reset, token: Digest::SHA1.hexdigest(non_encrypted_token))
      @password_retrieval.save!
      request_params = { token: non_encrypted_token }
      Timecop.freeze(@password_retrieval.updated_at + hours_until_expiration.hours) do
        get :check_token_validity, params: request_params
        expect(response).to render_template 'password_retrieval/reset_password'
      end
    end
  end

  describe 'check if password updated' do
    it 'check if password and repassword do match' do
      password = "factorybotpassword"
      @user = FactoryBot.create(:user)
      @user.save!
      @password_retrieval = FactoryBot.create(:password_reset)
      @password_retrieval.save!
      request_params = { reset: { password: password, repassword: password, email: @user.email } }
      post :update_password, params: request_params
      expect(PasswordReset.where(user_email: @password_retrieval.user_email)).not_to exist
      expect(response).to redirect_to '/'
    end

    it 'check if password validation fails' do
      invalid_password = "."
      @user = FactoryBot.create(:user)
      @user.save!
      @password_retrieval = FactoryBot.create(:password_reset)
      @password_retrieval.save!
      request_params = { reset: { password: invalid_password, repassword: invalid_password, email: @user.email } }
      post :update_password, params: request_params
      expect(response).to redirect_to '/'
      expect(flash[:error]).to be_present
    end

    it 'checks if password and repassword do not match' do
      password = "factorybotpassword"
      repassword = "notafactorybotpassword"
      @user = FactoryBot.create(:user)
      @user.save!
      @password_retrieval = FactoryBot.create(:password_reset)
      @password_retrieval.save!
      request_params = { reset: { password: password, repassword: repassword, email: @user.email } }
      post :update_password, params: request_params
      expect(PasswordReset.where(user_email: @password_retrieval.user_email)).to exist
      expect(response).to render_template 'password_retrieval/reset_password'
      expect(flash[:error]).to be_present
    end
  end
end
