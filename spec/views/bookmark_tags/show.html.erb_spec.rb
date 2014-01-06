require 'spec_helper'

describe "/bookmark_tags/show.html.erb" do
  include BookmarkTagsHelper
  before(:each) do
    assigns[:bookmark_tag] = @bookmark_tag = stub_model(BookmarkTag,
      :tag_name => "value for tag_name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ tag_name/)
  end
end
