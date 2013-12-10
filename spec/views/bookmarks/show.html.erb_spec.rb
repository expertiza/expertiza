require 'spec_helper'

describe "/bookmarks/show.html.erb" do
  include BookmarksHelper
  before(:each) do
    assigns[:bookmark] = @bookmark = stub_model(Bookmark)
  end

  it "renders attributes in <p>" do
    render
  end
end
