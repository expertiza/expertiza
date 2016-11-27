require 'rails_helper'

describe PasswordRetrievalController do
  describe "password reset" do
    it "create new entry in password_resets table" do
      user = build(:student)
      post :send_password, email: user.email
      expect(PasswordReset.where(user: user)).to exist
    end
  end

end