class ExportFileController < ApplicationController
  require 'fastercsv'

  def start
    @model = params[:model]
    if(@model == 'Assignment')
      @title = 'Grades'
    end
    @id = params[:id]

  end

  def export
    filename = "out.csv"
    csv_data = FasterCSV.generate do |csv|
      csv << Object.const_get(params[:model]).get_export_fields(params[:options])

      Object.const_get(params[:model]).export(csv, params[:id],params[:options])
    end

    send_data csv_data,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{filename}"
  end
end
