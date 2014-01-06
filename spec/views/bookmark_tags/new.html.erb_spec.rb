require 'spec_helper'

describe "/bookmark_tags/new.html.erb" do
  include BookmarkTagsHelper

  before(:each) do
    assigns[:bookmark_tag] = stub_model(BookmarkTag,
      :new_record? => true,
      :tag_name => "value for tag_name"
    )
  end

  it "renders new bookmark_tag form" do
    render

    response.should have_tag("form[action=?][method=post]", bookmark_tags_path) do
      with_tag("input#bookmark_tag_tag_name[name=?]", "bookmark_tag[tag_name]")
    end
  end
end
