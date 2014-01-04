require 'spec_helper'

describe "/bookmarks/new.html.erb" do
  include BookmarksHelper

  before(:each) do
    assigns[:bookmark] = stub_model(Bookmark,
      :new_record? => true
    )
  end

  it "renders new bookmark form" do
    render

    response.should have_tag("form[action=?][method=post]", bookmarks_path) do
    end
  end
end
