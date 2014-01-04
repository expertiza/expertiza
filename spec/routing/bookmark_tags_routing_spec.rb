require 'spec_helper'

describe BookmarkTagsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/bookmark_tags" }.should route_to(:controller => "bookmark_tags", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/bookmark_tags/new" }.should route_to(:controller => "bookmark_tags", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/bookmark_tags/1" }.should route_to(:controller => "bookmark_tags", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/bookmark_tags/1/edit" }.should route_to(:controller => "bookmark_tags", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/bookmark_tags" }.should route_to(:controller => "bookmark_tags", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/bookmark_tags/1" }.should route_to(:controller => "bookmark_tags", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/bookmark_tags/1" }.should route_to(:controller => "bookmark_tags", :action => "destroy", :id => "1") 
    end
  end
end
