require 'spec_helper'

describe "/bookmarks/edit.html.erb" do
  include BookmarksHelper

  before(:each) do
    assigns[:bookmark] = @bookmark = stub_model(Bookmark,
      :new_record? => false
    )
  end

  it "renders the edit bookmark form" do
    render

    response.should have_tag("form[action=#{bookmark_path(@bookmark)}][method=post]") do
    end
  end
end
