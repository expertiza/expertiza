class ExportFileController < ApplicationController
  require 'fastercsv'

  def start
    @model = params[:model]
    if(@model == 'Assignment')
      @title = 'Grades'
    elsif(@model == 'CourseParticipant')
      @title = 'Course Participants'
    elsif(@model == 'AssignmentTeam')
      @title = 'Teams'
    elsif(@model == 'CourseTeam')
      @title = 'Teams'
    elsif(@model == 'User')
      @title = 'Users'
    end
    @id = params[:id]
  end

  def export
    @delim_type = params[:delim_type]

    if(@delim_type == "comma")
      filename = "out.csv"
      delimiter = ","
    elsif(@delim_type == "space")
      filename = "out.csv"
      delimiter = " "
    elsif(@delim_type == "tab")
      filename = "out.tsv"
      delimiter = "\t"
    elsif(@delim_type == "other")
      filename = "out.txt"
      delimiter = other_char
    end
    csv_data = FasterCSV.generate(:col_sep => delimiter) do |csv|
      csv << Object.const_get(params[:model]).get_export_fields(params[:options])

      Object.const_get(params[:model]).export(csv, params[:id],params[:options])
    end

    send_data csv_data,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{filename}"
  end
end
