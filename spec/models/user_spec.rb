require 'rails_helper'
require 'will_paginate/array'

describe User do
  let(:user) { User.new name: "abc", fullname: "abc xyz", email: "abcxyz@gmail.com", password: "12345678", password_confirmation: "12345678" }

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

  #These methods test get_user_list
  describe "#get_user_list" do

    it "returns the list of all users for an instructor" do
      instructor = create(:instructor)
      student = create(:student)
      admin = create(:admin)
      allow(instructor).to receive(:can_impersonate?) {true}
      allow(instructor).to receive(:can_impersonate?).with(admin) {false}

      @users = instructor.get_user_list(1, nil)
      expect(@users.size).to eq(2)
    end

    it "returns the list of all users for a super-admin" do
      super_admin = create(:super_admin)
      instructor = create(:instructor)
      student = create(:student)
      admin = create(:admin)
      allow(super_admin).to receive(:can_impersonate?) {true}

      @users = super_admin.get_user_list(1, 25)
      expect(@users.size).to eq(4)
    end

  end
end
