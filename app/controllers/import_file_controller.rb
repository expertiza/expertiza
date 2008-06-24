class ImportFileController < ApplicationController
  
  def start
    @expected_fields = params[:expected_fields]
    @model = params[:model]            
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
    begin      
       importFile(file,session,delimiter,params[:model])       
    rescue ArgumentError             
       flash[:error] = 'An unexpected number of columns were received.' + $!
    end 
   redirect_to session[:return_to] 
 end
 
   def importFile(file,session,delimiter,model)
    while (line = file.gets)      
      if delimiter == ","
         items = line.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)
      else
         items = line.split(delimiter)
      end
      row = Array.new
      items.each { | value | row << value.sub("\"","").sub("\"","").strip }
      Object.const_get(model).import(row,session)
    end    
  end

    
end