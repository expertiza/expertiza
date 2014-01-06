require 'spec_helper'

describe BookmarkTag do
  before(:each) do
    @valid_attributes = {
      :tag_name => "value for tag_name"
    }
  end

  it "should create a new instance given valid attributes" do
    BookmarkTag.create!(@valid_attributes)
  end
end
