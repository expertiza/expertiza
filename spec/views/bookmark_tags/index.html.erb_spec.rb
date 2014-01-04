require 'spec_helper'

describe "/bookmark_tags/index.html.erb" do
  include BookmarkTagsHelper

  before(:each) do
    assigns[:bookmark_tags] = [
      stub_model(BookmarkTag,
        :tag_name => "value for tag_name"
      ),
      stub_model(BookmarkTag,
        :tag_name => "value for tag_name"
      )
    ]
  end

  it "renders a list of bookmark_tags" do
    render
    response.should have_tag("tr>td", "value for tag_name".to_s, 2)
  end
end
