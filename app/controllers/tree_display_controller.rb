class TreeDisplayController < ApplicationController
  
  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list 
    @show = params[:show]
    @sortvar = params[:sortvar]
    if @sortvar == nil
      @sortvar = 'name'
    end
    @sortorder = params[:sortorder]
    if @sortorder == nil
      @sortorder = 'asc'
    end
    @root = params[:root]
  end    
end
