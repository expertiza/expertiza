require 'spec_helper'

describe BookmarksController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/bookmarks" }.should route_to(:controller => "bookmarks", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/bookmarks/new" }.should route_to(:controller => "bookmarks", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/bookmarks/1" }.should route_to(:controller => "bookmarks", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/bookmarks/1/edit" }.should route_to(:controller => "bookmarks", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/bookmarks" }.should route_to(:controller => "bookmarks", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/bookmarks/1" }.should route_to(:controller => "bookmarks", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/bookmarks/1" }.should route_to(:controller => "bookmarks", :action => "destroy", :id => "1") 
    end
  end
end
