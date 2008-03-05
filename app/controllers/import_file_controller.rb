class ImportFileController < ApplicationController
  
  def start
    @import_type = params[:import_type]            
  end
  
  def import
    delim_type = params[:delim_type]
    delimiter = case delim_type
      when "comma": ","
      when "space": " "
      when "tab": "\t"
      when "other": params[:other_char]
    end 
    file = params['file']    
    if delim_type == "comma"
      ImportFileHelper::import_csv(file,session)
    end    
    redirect_to session[:return_to] 
  end
end
