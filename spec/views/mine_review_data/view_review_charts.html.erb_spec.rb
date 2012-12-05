require 'spec_helper'

describe "/mine_review_data/view_review_charts" do
  before(:each) do
    render 'mine_review_data/view_review_charts'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/mine_review_data/view_review_charts])
  end
end
