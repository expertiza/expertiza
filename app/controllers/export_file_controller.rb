class ExportFileController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  # Assign titles to model for display
  def start
    @model = params[:model]
    titles = {"Assignment" => "Grades", "CourseParticipant" => "Course Participants", "AssignmentTeam" => "Teams",
              "CourseTeam" => "Teams", "User" => "Users", "Question" => "Questions"}
    @title = titles[@model]
    @id = params[:id]
  end

  # Find the filename and delimiter
  def find_delim_filename(delim_type, other_char, suffix = "")
    if delim_type == "comma"
      filename = params[:model] + params[:id] + suffix + ".csv"
      delimiter = ","
    elsif delim_type == "space"
      filename = params[:model] + params[:id] + suffix + ".csv"
      delimiter = " "
    elsif delim_type == "tab"
      filename = params[:model] + params[:id] + suffix + ".csv"
      delimiter = "\t"
    elsif delim_type == "other"
      filename = params[:model] + params[:id] + suffix + ".csv"
      delimiter = other_char
    end
    [filename, delimiter]
  end

  def exportdetails
    @delim_type = params[:delim_type2]
    filename, delimiter = find_delim_filename(@delim_type, params[:other_char2], "_Details")

    allowed_models = ['Assignment']

    csv_data = CSV.generate(col_sep: delimiter) do |csv|
      if allowed_models.include? params[:model]
        csv << Object.const_get(params[:model]).export_headers(params[:id])
        csv << Object.const_get(params[:model]).export_details_fields(params[:details])
        Object.const_get(params[:model]).export_details(csv, params[:id], params[:details])
      end
    end

    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=#{filename}"
  end

  def export
    @delim_type = params[:delim_type]
    filename, delimiter = find_delim_filename(@delim_type, params[:other_char])

    allowed_models = %w[Assignment
                        AssignmentParticipant
                        AssignmentTeam
                        CourseParticipant
                        CourseTeam
                        MetareviewResponseMap
                        Question
                        ReviewResponseMap
                        User
                        Team]
    csv_data = CSV.generate(col_sep: delimiter) do |csv|
      if allowed_models.include? params[:model]
        csv << Object.const_get(params[:model]).export_fields(params[:options])
        Object.const_get(params[:model]).export(csv, params[:id], params[:options])
      end
    end

    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=#{filename}"
  end

  # Export question advice data to CSV file
  def export_advices
    @delim_type = params[:delim_type]
    filename, delimiter = find_delim_filename(@delim_type, params[:other_char])

    allowed_models = ['Question']
    advice_model = 'QuestionAdvice'

    csv_data = CSV.generate(col_sep: delimiter) do |csv|
      if allowed_models.include? params[:model]
        csv << Object.const_get(advice_model).export_fields(params[:options])
        Object.const_get(advice_model).export(csv, params[:id], params[:options])
      end
    end

    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=#{filename}"
  end
end
