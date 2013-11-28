class ExportFileController < ApplicationController
  # OSS808 Change 28/10/2013
  # FasterCSV replaced now by CSV which is present by default in Ruby
  #require 'fastercsv'
  #added the below lines E913
  include AccessHelper
  before_filter :auth_check

  def action_allowed?
    if current_user.role.name.eql?("Instructor") || current_user.role.name.eql?("Teaching-Assistant") || current_user.role.name.eql?("Administrator") || current_user.role.name.eql?("Super-Administrator")
      true
    end
  end

#our changes end E913
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
    csv_data = CSV.generate(:col_sep => delimiter) do |csv|
      csv << Object.const_get(params[:model]).get_export_fields(params[:options])

      Object.const_get(params[:model]).export(csv, params[:id],params[:options])
    end

    send_data csv_data,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{filename}"
  end
end
