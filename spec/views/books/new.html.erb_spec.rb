require 'spec_helper'

describe "/books/new.html.erb" do
  include BooksHelper

  before(:each) do
    assigns[:book] = stub_model(Book,
      :new_record? => true
    )
  end

  it "renders new book form" do
    render

    response.should have_tag("form[action=?][method=post]", books_path) do
    end
  end
end
