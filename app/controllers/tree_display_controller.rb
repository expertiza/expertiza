class TreeDisplayController < ApplicationController
  
  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list  
    if session[:display]      
      @sortvar = session[:display][:sortvar]
      @sortorder = session[:display][:sortorder]
      if session[:display][:check] == "1"
        @show = nil
      else
        @show = session[:user].id
      end
    end
    if params[:display]      
      @sortvar = params[:display][:sortvar]
      @sortorder = params[:display][:sortorder] 
      if params[:display][:check] == "1"
        @show = nil
      else
        @show = session[:user].id
      end
      session[:display] = params[:display]      
    end
  
    if session[:display].nil? and params[:display].nil?
      @show = session[:user].id
    end
    
    if @sortvar == nil
      @sortvar = 'name'
    end
    if @sortorder == nil
      @sortorder = 'asc'
    end
        
    if session[:root]
      @root_node = Node.find(session[:root])
      @child_nodes = @root_node.get_children(@sortvar,@sortorder,@show)
    else
      @child_nodes = FolderNode.get()
    end    
  end   
  
  def drill
    session[:root] = params[:root]
    redirect_to :controller => 'tree_display', :action => 'list'
  end
end
