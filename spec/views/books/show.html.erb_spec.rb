require 'spec_helper'

describe "/books/show.html.erb" do
  include BooksHelper
  before(:each) do
    assigns[:book] = @book = stub_model(Book)
  end

  it "renders attributes in <p>" do
    render
  end
end
