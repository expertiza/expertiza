require 'spec_helper'

describe BookmarkTagsController do

  def mock_bookmark_tag(stubs={})
    @mock_bookmark_tag ||= mock_model(BookmarkTag, stubs)
  end

  describe "GET index" do
    it "assigns all bookmark_tags as @bookmark_tags" do
      BookmarkTag.stub(:find).with(:all).and_return([mock_bookmark_tag])
      get :index
      assigns[:bookmark_tags].should == [mock_bookmark_tag]
    end
  end

  describe "GET show" do
    it "assigns the requested bookmark_tag as @bookmark_tag" do
      BookmarkTag.stub(:find).with("37").and_return(mock_bookmark_tag)
      get :show, :id => "37"
      assigns[:bookmark_tag].should equal(mock_bookmark_tag)
    end
  end

  describe "GET new" do
    it "assigns a new bookmark_tag as @bookmark_tag" do
      BookmarkTag.stub(:new).and_return(mock_bookmark_tag)
      get :new
      assigns[:bookmark_tag].should equal(mock_bookmark_tag)
    end
  end

  describe "GET edit" do
    it "assigns the requested bookmark_tag as @bookmark_tag" do
      BookmarkTag.stub(:find).with("37").and_return(mock_bookmark_tag)
      get :edit, :id => "37"
      assigns[:bookmark_tag].should equal(mock_bookmark_tag)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created bookmark_tag as @bookmark_tag" do
        BookmarkTag.stub(:new).with({'these' => 'params'}).and_return(mock_bookmark_tag(:save => true))
        post :create, :bookmark_tag => {:these => 'params'}
        assigns[:bookmark_tag].should equal(mock_bookmark_tag)
      end

      it "redirects to the created bookmark_tag" do
        BookmarkTag.stub(:new).and_return(mock_bookmark_tag(:save => true))
        post :create, :bookmark_tag => {}
        response.should redirect_to(bookmark_tag_url(mock_bookmark_tag))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bookmark_tag as @bookmark_tag" do
        BookmarkTag.stub(:new).with({'these' => 'params'}).and_return(mock_bookmark_tag(:save => false))
        post :create, :bookmark_tag => {:these => 'params'}
        assigns[:bookmark_tag].should equal(mock_bookmark_tag)
      end

      it "re-renders the 'new' template" do
        BookmarkTag.stub(:new).and_return(mock_bookmark_tag(:save => false))
        post :create, :bookmark_tag => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested bookmark_tag" do
        BookmarkTag.should_receive(:find).with("37").and_return(mock_bookmark_tag)
        mock_bookmark_tag.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bookmark_tag => {:these => 'params'}
      end

      it "assigns the requested bookmark_tag as @bookmark_tag" do
        BookmarkTag.stub(:find).and_return(mock_bookmark_tag(:update_attributes => true))
        put :update, :id => "1"
        assigns[:bookmark_tag].should equal(mock_bookmark_tag)
      end

      it "redirects to the bookmark_tag" do
        BookmarkTag.stub(:find).and_return(mock_bookmark_tag(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(bookmark_tag_url(mock_bookmark_tag))
      end
    end

    describe "with invalid params" do
      it "updates the requested bookmark_tag" do
        BookmarkTag.should_receive(:find).with("37").and_return(mock_bookmark_tag)
        mock_bookmark_tag.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bookmark_tag => {:these => 'params'}
      end

      it "assigns the bookmark_tag as @bookmark_tag" do
        BookmarkTag.stub(:find).and_return(mock_bookmark_tag(:update_attributes => false))
        put :update, :id => "1"
        assigns[:bookmark_tag].should equal(mock_bookmark_tag)
      end

      it "re-renders the 'edit' template" do
        BookmarkTag.stub(:find).and_return(mock_bookmark_tag(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested bookmark_tag" do
      BookmarkTag.should_receive(:find).with("37").and_return(mock_bookmark_tag)
      mock_bookmark_tag.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the bookmark_tags list" do
      BookmarkTag.stub(:find).and_return(mock_bookmark_tag(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(bookmark_tags_url)
    end
  end

end
