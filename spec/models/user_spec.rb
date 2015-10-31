require "spec_helper"

describe User do
  before :each do
    @user = User.new name: "abc", fullname: "abc xyz", email: "abcxyz@gmail.com", password: "12345678", password_confirmation: "12345678"
  end
  describe "#new" do
    it "Validate user instance creation with valid parameters" do
      @user.should be_an_instance_of User
    end
  end

  describe "#name" do
    it "returns the name of the user" do
      @user.name.should eql "abc"
    end
    it "Validate presence of name which cannot be blank" do
      user1 = User.new fullname: "abc bbc", email: "abcbbc@gmail.com", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end
    it "Validate that name is always unique" do
      @user0 = User.new name: "abc", fullname: "abc dbc", email: "abcdbc@gmail.com", password: "12345678", password_confirmation: "12345678"
      @user1 = User.new name: "abc", fullname: "abc bbc", email: "abcbbc@gmail.com", password: "123456789", password_confirmation: "123456789"
      @user1.should validate_uniqueness_of(:name)
    end
  end

  describe "#fullname" do
    it "returns the full name of the user" do
      @user.fullname.should eql "abc xyz"
    end
  end

  describe "#email" do
    it "returns the email of the user" do
      @user.email.should eql "abcxyz@gmail.com"
    end

    it "Validate presence of email which cannot be blank" do
      user1 = User.new name: "abc", fullname: "abc bbc", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end

    it "Validate the email format" do
      user1 = User.new name: "abc123", fullname: "abc bbc", email: "a@x", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end

    it "Validate the email format" do
      user1 = User.new name: "abc123", fullname: "abc bbc", email: "ax.com", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end

    it "Validate the email format" do
      user1 = User.new name: "abc123", fullname: "abc bbc", email: "axc", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end

    it "Validate the email format" do
      user1 = User.new name: "abc123", fullname: "abc bbc", email: "123", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end

    it "Validate the email format" do
      user1 = User.new name: "abc123", fullname: "abc bbc", email: " ", password: "123456789", password_confirmation: "123456789"
      user1.should_not be_valid
    end

    it "Validate the email format correctness" do
      user1 = User.new name: "abc123", fullname: "abc bbc", email: "a@x.com", password: "123456789", password_confirmation: "123456789"
      user1.should be_valid
    end
  end
end