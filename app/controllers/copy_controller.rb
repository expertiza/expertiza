class CopyController < ApplicationController
  
  def copy
    begin
      @model = params[:model]
      @object = Object.const_get(params[:model]).find(params[:id])
      @id = params[:id]
    rescue
      flash[:error] = "The model, #{@model}, is not defined."
      redirect_to :back      
    end
  end
  
  def save    
    msg = Object.const_get(params[:model]).find(params[:id]).copy(params)
    logger.info "** #{msg.class.to_s}"
    if msg.class.to_s == "String" and msg.length > 0
      flash[:error] = msg
      redirect_to :controller=>'copy', :action=>'copy', :id =>params[:id], :model => params[:model]      
    else
      redirect_to :controller=>params[:model], :action=>'list'
    end
  end
end
