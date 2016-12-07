require 'rails_helper'

describe "validations" do
  before(:each) do
    @chat = build(:chat)
  end


  it "chat is valid" do

    expect(@chat).to be_valid
  end

  it "The assignment_team_id of a chat is unique" do


    expect(@chat).to validate_uniqueness_of(:assignment_team_id)

  end

end
