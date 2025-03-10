class ExportFileController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Assign titles to model for display
  def start
    @model = params[:model]
    titles = { 'Assignment' => 'Grades', 'CourseParticipant' => 'Course Participants', 'AssignmentTeam' => 'Teams',
               'CourseTeam' => 'Teams', 'User' => 'Users', 'Question' => 'Questions' }
    @title = titles[@model]
    @id = params[:id]
  end

  # Find the filename and delimiter
  def find_delim_filename(delim_type, other_char, suffix = '')
    if delim_type == 'comma'
      filename = params[:model] + params[:id] + suffix + '.csv'
      delimiter = ','
    elsif delim_type == 'space'
      filename = params[:model] + params[:id] + suffix + '.csv'
      delimiter = ' '
    elsif delim_type == 'tab'
      filename = params[:model] + params[:id] + suffix + '.csv'
      delimiter = "\t"
    elsif delim_type == 'other'
      filename = params[:model] + params[:id] + suffix + '.csv'
      delimiter = other_char
    end
    [filename, delimiter]
  end

  def exportdetails
    @delim_type = params[:delim_type2]
    filename, delimiter = find_delim_filename(@delim_type, params[:other_char2], '_Details')

    allowed_models = ['Assignment']
    # The export_details_fields and export_headers methods are defined in Assignment.rb that packs all the details from
    # the model in the generated CSV file.
    csv_data = CSV.generate(col_sep: delimiter) do |csv|
      if allowed_models.include? params[:model]
        csv << Object.const_get(params[:model]).export_headers(params[:id])
        csv << Object.const_get(params[:model]).export_details_fields(params[:details])
        Object.const_get(params[:model]).export_details(csv, params[:id], params[:details])
      else
        flash[:error] = "This operation is not supported for #{params[:model]}"
        redirect_back fallback_location: root_path
        return nil
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

  def export_tags
    @user_ids = User.where('username IN (?)', params[:names])
    @students = AnswerTag.select('answers.*, answer_tags.*').joins(:answer).where('answer_tags.answer_id = answers.id and answer_tags.user_id IN (?)', @user_ids.pluck(:id))
    attributes = %w[user_id tag_prompt_deployment_id comments value]

    csv_data = CSV.generate(col_sep: ',') do |csv|
      csv << attributes
      @students.each do |item|
        csv << item.attributes.values_at(*attributes)
      end
    end
    filename = 'Tags'

    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=#{filename}.csv"
  end
end
