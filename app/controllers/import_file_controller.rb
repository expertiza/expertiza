class ImportFileController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  def start
    @id = params[:id]
    @expected_fields = params[:expected_fields]
    @model = params[:model]
    @title = params[:title]
    @array_expected_values = parse_line(@expected_fields,',',params)
    b = ['...','MetareviewerN','ReviewerN','Team MemberN']
    @array_expected_values.delete_if { |x| b.include?(x) }

    if(@array_expected_values.include?("Team Member1"))
    (3..4).each do |i|
      @array_expected_values.push("Team Member#{i}")
    end
    elsif(@array_expected_values.include?("Reviewer1"))
    (3..15).each do |i|
      @array_expected_values.push("Reviewer#{i}")
    end
    elsif(@array_expected_values.include?("Metaeviewer1"))
    (3..15).each do |i|
      @array_expected_values.push("Metareviewer#{i}")
    end
    else
    end
  end

  def import
    errors = importFile(session, params)
    err_msg = "The following errors were encountered during import.<br/>Other records may have been added. A second submission will not duplicate these records.<br/><ul>"
    errors.each do |error|
      err_msg = err_msg + "<li>" + error.to_s + "<br/>"
    end
    err_msg += "</ul>"
    flash[:error] = err_msg unless errors.empty?
    undo_link("The file has been successfully imported.")
    redirect_to session[:return_to]
  end

  protected

  def importFile(session, params)
    delimiter = get_delimiter(params)
    file = params['file'].tempfile

    logger.debug "the value of file is passed: #{file}"
    errors = []
    first_row_read = false
    row_header = {}
    file.each_line do |line|
      line.chomp!
      if first_row_read == false
        row_header = parse_line(line.downcase, delimiter,params)
        first_row_read = true
        if row_header.include?("email")
          # skip if first row contains header. In case of user information, it will contain name of user (mandatory
          next
        else
          row_header = {}
        end
      end
      next if line.empty?
      row = parse_line(line, delimiter,params)
      begin
        if params[:model] == 'AssignmentTeam' or params[:model] == 'CourseTeam'
          Object.const_get(params[:model]).import(row, params[:id], params[:options])
        elsif params[:model] == 'SignUpTopic'
          session[:assignment_id] = params[:id]
          Object.const_get(params[:model]).import(row, session, params[:id])
        else
          if row_header.count > 0
            Object.const_get(params[:model]).import(row, row_header, session, params[:id])
          else
            Object.const_get(params[:model]).import(row, nil, session, params[:id])
          end
        end
      rescue
        errors << $ERROR_INFO
      end
    end
    errors
  end

  def get_delimiter(params)
    delim_type = params[:delim_type]
    delimiter = case delim_type
                when "comma" then ","
                when "space" then " "
                when "tab" then "\t"
                when "other" then params[:other_char]
                end
    delimiter
  end

  def parse_line(line, delimiter,params)
    items = if delimiter == ","
              line.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)
            else
              line.split(delimiter)
            end
    row = []
    items.each {|value| row << value.sub("\"", "").sub("\"", "").strip }
    reordered_row=[]
    reordered_row=reorder_row(row,params)
    if (reordered_row[0].nil?)
      row
    else
      reordered_row
    end
  end
  def reorder_row(row,params)
    case params[:model]
      when "AssignmentTeam"
        expected_fields_variable_default = ['Team Name - optional', 'Team Member1','Team Member2', 'Team Member3', 'Team Member4']
      when "User"
        expected_fields_variable_default = [ 'username', 'full name (first[ middle] last)', 'e-mail address']
      when "ReviewResponseMap"
        expected_fields_variable_default = [ 'Contributor', 'Reviewer1', 'Reviewer2']
        (3..15).each do |i|
          expected_fields_variable_default.push("Reviewer#{i}")
        end
      when "MetaeviewResponseMap"
        expected_fields_variable_default = [ 'Contributor', 'Reviewer', 'Metareviewer1','Metareviewer2']
        (3..15).each do |i|
          expected_fields_variable_default.push("Metareviewer#{i}")
        end
      else
        expected_fields_variable_default = ['Team Name - optional', 'Team Member1','Team Member2', 'Team Member3', 'Team Member4']
    end

    expected_fields_variable=[]
    custom_order={}
    return_row=[]
    expected_fields_variable=expected_fields_variable_default.reject.with_index { |x,i| i > row.length-1 }
    expected_fields_variable.each_with_index { |field, index|
      custom_order[params["import_field_#{index}"]]=row[index]
    }
    expected_fields_variable.each_with_index { |field, index| return_row[index]=custom_order[field]}
    return_row
  end
  # def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => Object.const_get(params[:model]).last.versions.last.id)}>undo</a>"
  # end
end
