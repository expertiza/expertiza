describe PasswordRetrievalController do
  describe "password reset" do
    it "create new entry in password_resets table" do
      @user = User.new
      @user.email = "example@example.edu"
      @user.name = "ex"
      @user.save!
      post :send_password, user: {email: "example@example.edu"}
      expect(PasswordReset.where(user_email: "example@example.edu")).to exist
    end
    it "modifies the token in password_resets_table" do
      @user = User.new
      @user.email = "example@example.edu"
      @user.name = "Shubham"
      @user.save!
      @password_retrival = PasswordReset.new
      @local_token = "some random string"
      @password_retrival.token = @local_token
      @password_retrival.user_email = "example@example.edu"
      @password_retrival.save!
      post :send_password, user: {email: "example@example.edu"}
      expect(PasswordReset.find_by(user_email: "example@example.edu").token).not_to eq(@local_token)
    end
    it "if no user no entry is created" do
      @user = User.new
      @user.email = "aexample@example.edu"
      @user.name = "Shubham"
      @user.save!
      post :send_password, user: {email: "example@example.edu"}
      expect(PasswordReset.where(user_email: "example@example.edu")).not_to exist
    end
  end

  describe "check if token is expired" do
    it "checks when token is expired" do
      local_token = "some random string"
      @password_retrival = PasswordReset.new
      @password_retrival.token = Digest::SHA1.hexdigest(local_token)
      @password_retrival.user_email = "example@example.edu"
      @password_retrival.save!

      Timecop.freeze(Time.zone.today + 2.days) do
        get :check_reset_url, token: local_token
        expect(response).to render_template "password_retrieval/forgotten"
      end
    end

    it "checks when token does not exist" do
      local_token = "some random strin"
      local_token_sent_as_parameter = "randome some"
      @password_retrival = PasswordReset.new
      @password_retrival.token = Digest::SHA1.hexdigest(local_token)
      @password_retrival.user_email = "example@example.edu"
      @password_retrival.save!

      get :check_reset_url, token: local_token_sent_as_parameter
      expect(response).to render_template "password_retrieval/forgotten"
    end

    it "checks when token is not expired" do
      local_token = "some random string"
      @password_retrival = PasswordReset.new
      @password_retrival.token = Digest::SHA1.hexdigest(local_token)
      @password_retrival.user_email = "example@example.edu"
      @password_retrival.save!
      Timecop.freeze(@password_retrival.updated_at + 2.hours) do
        get :check_reset_url, token: local_token
        expect(response).to render_template "password_retrieval/reset_password"
      end
    end
  end
end
