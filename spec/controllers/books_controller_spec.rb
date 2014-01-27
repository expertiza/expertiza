require 'spec_helper'

describe BooksController do

  def mock_book(stubs={})
    @mock_book ||= mock_model(Book, stubs)
  end

  describe "GET index" do
    it "assigns all books as @books" do
      Book.stub(:find).with(:all).and_return([mock_book])
      get :index
      assigns[:books].should == [mock_book]
    end
  end

  describe "GET show" do
    it "assigns the requested book as @book" do
      Book.stub(:find).with("37").and_return(mock_book)
      get :show, :id => "37"
      assigns[:book].should equal(mock_book)
    end
  end

  describe "GET new" do
    it "assigns a new book as @book" do
      Book.stub(:new).and_return(mock_book)
      get :new
      assigns[:book].should equal(mock_book)
    end
  end

  describe "GET edit" do
    it "assigns the requested book as @book" do
      Book.stub(:find).with("37").and_return(mock_book)
      get :edit, :id => "37"
      assigns[:book].should equal(mock_book)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created book as @book" do
        Book.stub(:new).with({'these' => 'params'}).and_return(mock_book(:save => true))
        post :create, :book => {:these => 'params'}
        assigns[:book].should equal(mock_book)
      end

      it "redirects to the created book" do
        Book.stub(:new).and_return(mock_book(:save => true))
        post :create, :book => {}
        response.should redirect_to(book_url(mock_book))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved book as @book" do
        Book.stub(:new).with({'these' => 'params'}).and_return(mock_book(:save => false))
        post :create, :book => {:these => 'params'}
        assigns[:book].should equal(mock_book)
      end

      it "re-renders the 'new' template" do
        Book.stub(:new).and_return(mock_book(:save => false))
        post :create, :book => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested book" do
        Book.should_receive(:find).with("37").and_return(mock_book)
        mock_book.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :book => {:these => 'params'}
      end

      it "assigns the requested book as @book" do
        Book.stub(:find).and_return(mock_book(:update_attributes => true))
        put :update, :id => "1"
        assigns[:book].should equal(mock_book)
      end

      it "redirects to the book" do
        Book.stub(:find).and_return(mock_book(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(book_url(mock_book))
      end
    end

    describe "with invalid params" do
      it "updates the requested book" do
        Book.should_receive(:find).with("37").and_return(mock_book)
        mock_book.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :book => {:these => 'params'}
      end

      it "assigns the book as @book" do
        Book.stub(:find).and_return(mock_book(:update_attributes => false))
        put :update, :id => "1"
        assigns[:book].should equal(mock_book)
      end

      it "re-renders the 'edit' template" do
        Book.stub(:find).and_return(mock_book(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested book" do
      Book.should_receive(:find).with("37").and_return(mock_book)
      mock_book.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the books list" do
      Book.stub(:find).and_return(mock_book(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(books_url)
    end
  end

end
