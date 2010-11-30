class ExportFileController < ApplicationController
=begin
  require 'fastercsv'
  
  def start    
    filename = "out.csv"
    csv_data = FasterCSV.generate do |csv|
        csv << Object.const_get(params[:model]).get_export_fields()       
               
        Object.const_get(params[:model]).export(csv,params[:id])       
    end
       
    send_data csv_data, 
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{filename}"              
  end
=end
end
