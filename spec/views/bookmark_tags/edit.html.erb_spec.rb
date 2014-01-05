require 'spec_helper'

describe "/bookmark_tags/edit.html.erb" do
  include BookmarkTagsHelper

  before(:each) do
    assigns[:bookmark_tag] = @bookmark_tag = stub_model(BookmarkTag,
      :new_record? => false,
      :tag_name => "value for tag_name"
    )
  end

  it "renders the edit bookmark_tag form" do
    render

    response.should have_tag("form[action=#{bookmark_tag_path(@bookmark_tag)}][method=post]") do
      with_tag('input#bookmark_tag_tag_name[name=?]', "bookmark_tag[tag_name]")
    end
  end
end
