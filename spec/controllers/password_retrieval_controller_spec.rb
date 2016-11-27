require 'rails_helper'

describe PasswordRetrievalController do
  describe "password reset" do
    it "create new entry in password_resets table" do
      @user = User.new
      @user.email = "gsshubha@ncsu.edu"
      @user.name = "Shubham"
      @user.save!
      post :send_password, {user: {email: "gsshubha@ncsu.edu"}}
      expect(PasswordReset.where(user_email: "gsshubha@ncsu.edu")).to exist
    end
    it "modifies the token in password_resets_table" do
      @user = User.new
      @user.email = "gsshubha@ncsu.edu"
      @user.name = "Shubham"
      @user.save!
      @password_retrival = PasswordReset.new
      @local_token = "some random string"
      @password_retrival.token = @local_token
      @password_retrival.user_email = "gsshubha@ncsu.edu"
      @password_retrival.save!
      post :send_password, {user: {email: "gsshubha@ncsu.edu"}}
      expect(PasswordReset.find_by(user_email: "gsshubha@ncsu.edu").token).not_to eq(@local_token)
    end
    it "if no user no entry is created" do
      @user = User.new
      @user.email = "agsshubha@ncsu.edu"
      @user.name = "Shubham"
      @user.save!
      post :send_password, {user: {email: "gsshubha@ncsu.edu"}}
      expect(PasswordReset.where(user_email: "gsshubha@ncsu.edu")).not_to exist
    end
  end

end