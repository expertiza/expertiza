require 'spec_helper'

describe "/books/edit.html.erb" do
  include BooksHelper

  before(:each) do
    assigns[:book] = @book = stub_model(Book,
      :new_record? => false
    )
  end

  it "renders the edit book form" do
    render

    response.should have_tag("form[action=#{book_path(@book)}][method=post]") do
    end
  end
end
