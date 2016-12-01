require 'rails_helper'

describe "validations" do
  before(:each) do
    @chat = create(:chat)
  end


  it "chat is valid" do

    expect(@chat).to be_valid
  end

  it "The review_response_map_id of a chat is unique" do


    expect(@chat).to validate_uniqueness_of(:review_response_map_id)

  end

end


