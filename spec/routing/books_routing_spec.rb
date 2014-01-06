require 'spec_helper'

describe BooksController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/books" }.should route_to(:controller => "books", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/books/new" }.should route_to(:controller => "books", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/books/1" }.should route_to(:controller => "books", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/books/1/edit" }.should route_to(:controller => "books", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/books" }.should route_to(:controller => "books", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/books/1" }.should route_to(:controller => "books", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/books/1" }.should route_to(:controller => "books", :action => "destroy", :id => "1") 
    end
  end
end
