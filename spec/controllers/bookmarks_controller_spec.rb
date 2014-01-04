require 'spec_helper'

describe BookmarksController do

  def mock_bookmark(stubs={})
    @mock_bookmark ||= mock_model(Bookmark, stubs)
  end

  describe "GET index" do
    it "assigns all bookmarks as @bookmarks" do
      Bookmark.stub(:find).with(:all).and_return([mock_bookmark])
      get :index
      assigns[:bookmarks].should == [mock_bookmark]
    end
  end

  describe "GET show" do
    it "assigns the requested bookmark as @bookmark" do
      Bookmark.stub(:find).with("37").and_return(mock_bookmark)
      get :show, :id => "37"
      assigns[:bookmark].should equal(mock_bookmark)
    end
  end

  describe "GET new" do
    it "assigns a new bookmark as @bookmark" do
      Bookmark.stub(:new).and_return(mock_bookmark)
      get :new
      assigns[:bookmark].should equal(mock_bookmark)
    end
  end

  describe "GET edit" do
    it "assigns the requested bookmark as @bookmark" do
      Bookmark.stub(:find).with("37").and_return(mock_bookmark)
      get :edit, :id => "37"
      assigns[:bookmark].should equal(mock_bookmark)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created bookmark as @bookmark" do
        Bookmark.stub(:new).with({'these' => 'params'}).and_return(mock_bookmark(:save => true))
        post :create, :bookmark => {:these => 'params'}
        assigns[:bookmark].should equal(mock_bookmark)
      end

      it "redirects to the created bookmark" do
        Bookmark.stub(:new).and_return(mock_bookmark(:save => true))
        post :create, :bookmark => {}
        response.should redirect_to(bookmark_url(mock_bookmark))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bookmark as @bookmark" do
        Bookmark.stub(:new).with({'these' => 'params'}).and_return(mock_bookmark(:save => false))
        post :create, :bookmark => {:these => 'params'}
        assigns[:bookmark].should equal(mock_bookmark)
      end

      it "re-renders the 'new' template" do
        Bookmark.stub(:new).and_return(mock_bookmark(:save => false))
        post :create, :bookmark => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested bookmark" do
        Bookmark.should_receive(:find).with("37").and_return(mock_bookmark)
        mock_bookmark.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bookmark => {:these => 'params'}
      end

      it "assigns the requested bookmark as @bookmark" do
        Bookmark.stub(:find).and_return(mock_bookmark(:update_attributes => true))
        put :update, :id => "1"
        assigns[:bookmark].should equal(mock_bookmark)
      end

      it "redirects to the bookmark" do
        Bookmark.stub(:find).and_return(mock_bookmark(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(bookmark_url(mock_bookmark))
      end
    end

    describe "with invalid params" do
      it "updates the requested bookmark" do
        Bookmark.should_receive(:find).with("37").and_return(mock_bookmark)
        mock_bookmark.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bookmark => {:these => 'params'}
      end

      it "assigns the bookmark as @bookmark" do
        Bookmark.stub(:find).and_return(mock_bookmark(:update_attributes => false))
        put :update, :id => "1"
        assigns[:bookmark].should equal(mock_bookmark)
      end

      it "re-renders the 'edit' template" do
        Bookmark.stub(:find).and_return(mock_bookmark(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested bookmark" do
      Bookmark.should_receive(:find).with("37").and_return(mock_bookmark)
      mock_bookmark.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the bookmarks list" do
      Bookmark.stub(:find).and_return(mock_bookmark(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(bookmarks_url)
    end
  end

end
