#require "rspec"
#require_relative "../rails_helper"
require 'rails_helper'

describe User do
  
    let(:user){User.new name: "abc", fullname: "abc xyz", email: "abcxyz@gmail.com", password: "12345678", password_confirmation: "12345678", role_id: 1}
  
  describe "#new" do
    it "Validate user instance creation with valid parameters" do
      expect(user.class).to be(User)
    end
  end

  describe "#name" do
    it "returns the name of the user" do
      expect(user.name).to eq("abc")
    end
    it "Validate presence of name which cannot be blank" do
      expect(user).to be_valid
      user.name = '  '
      expect(user).not_to be_valid
    end
    it "Validate that name is always unique" do
      user1 = User.new name: "abc", fullname: "abc bbc", email: "abcbbc@gmail.com", password: "123456789", password_confirmation: "123456789"
      expect(user1).to validate_uniqueness_of(:name)
    end
  end

  describe "#fullname" do
    it "returns the full name of the user" do
      expect(user.fullname).to eq("abc xyz")
    end
  end

  describe "#email" do
    it "returns the email of the user" do
      expect(user.email).to eq("abcxyz@gmail.com")
    end

    it "Validate presence of email which cannot be blank" do
      user.email = '  '
      expect(user).not_to be_valid
    end

    it "Validate the email format" do
      user.email = 'a@x'
      expect(user).not_to be_valid
    end

    it "Validate the email format" do
      user.email = 'ax.com'
      expect(user).not_to be_valid
    end

    it "Validate the email format" do
      user.email = 'axc'
      expect(user).not_to be_valid
    end

    it "Validate the email format" do
      user.email = '123'
      expect(user).not_to be_valid
    end

    it "Validate the email format correctness" do
      user.email = 'a@x.com'
      expect(user).to be_valid
    end
  end


    # this test is to test the list of users under an instructor.
    describe "#get_user_list" do
      it 'user list' do
        @role = Role.new name: "Instructor"

        user1 = User.new name: "instructor4", role: @role
        expect(user1.get_user_list).to be_empty
        expect(user1.get_users_instructor)

      end
    end




end