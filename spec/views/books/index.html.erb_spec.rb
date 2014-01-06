require 'spec_helper'

describe "/books/index.html.erb" do
  include BooksHelper

  before(:each) do
    assigns[:books] = [
      stub_model(Book),
      stub_model(Book)
    ]
  end

  it "renders a list of books" do
    render
  end
end
