require 'rails_helper'

describe "On message create" do
  before(:each) do
    @message= create(:message)
  end

  it "message is valid" do

    expect(@message).to be_valid
  end

  it "message without body is not valid" do
    @message.body = nil
    @message.save
    expect(@message).not_to be_valid
  end

  it "message without chat_id is not valid" do
    @message.chat_id = nil
    @message.save
    expect(@message).not_to be_valid
  end

  it "message without user_id is not valid" do
    @message.user_id = nil
    @message.save
    expect(@message).not_to be_valid
  end
end