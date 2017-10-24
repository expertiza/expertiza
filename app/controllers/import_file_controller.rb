class ImportFileController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  def show
    @id = params[:id]
    @model = params[:model]
    @options = params[:options]
    @delimiter = get_delimiter(params)
    @has_header = params[:has_header]
    if (@model == 'AssignmentTeam'|| @model == 'CourseTeam')
      @has_teamname = params[:has_teamname]
    else
      @has_teamname = "nil"
    end
    if (@model == 'ReviewResponseMap')
      @has_reviewee = params[:has_reviewee]
    else
      @has_reviewee = nil
    end

    if (@model == 'MetareviewResponseMap')
      @has_reviewee = params[:has_reviewee]
      @has_reviewer = params[:has_reviewer]
    else
      @has_reviewee = "nil"
      @has_reviewer = "nil"
    end
    @current_file = params[:file]
    @current_file_contents = @current_file.read
    @contents_grid = parse_to_grid(@current_file_contents, @delimiter)
    @contents_hash = parse_to_hash(@contents_grid, params[:has_header])
  end

  def start
    @id = params[:id]
    @expected_fields = params[:expected_fields]
    @model = params[:model]
    @title = params[:title]
  end


  def import

    errors = import_from_hash(session, params)

    err_msg = "The following errors were encountered during import.<br/>Other records may have been added. A second submission will not duplicate these records.<br/><ul>"

    errors.each do |error|
      err_msg = err_msg + "<li>" + error.to_s + "<br/>"
    end

    err_msg += "</ul>"
    flash[:error] = err_msg unless errors.empty?
    undo_link("The file has been successfully imported.")
    redirect_to session[:return_to]

  end

  # def import
  #   errors = importFile(session, params)
  #   err_msg = "The following errors were encountered during import.<br/>Other records may have been added. A second submission will not duplicate these records.<br/><ul>"
  #   errors.each do |error|
  #     err_msg = err_msg + "<li>" + error.to_s + "<br/>"
  #   end
  #   err_msg += "</ul>"
  #   flash[:error] = err_msg unless errors.empty?
  #   undo_link("The file has been successfully imported.")
  #   redirect_to session[:return_to]
  # end


  def import_from_hash(session, params)

    if params[:model] == "AssignmentTeam" or params[:model] == "CourseTeam"

      contents_hash = eval(params[:contents_hash])
      @header_integrated_body = hash_rows_with_headers(contents_hash[:header],contents_hash[:body])
      errors = []

      begin

        @header_integrated_body.each do |row_hash|
          if params[:model] == "AssignmentTeam"
            teamtype = AssignmentTeam
          else
            teamtype = CourseTeam
          end
          options = eval(params[:options])
          options[:has_teamname] = params[:has_teamname]
          Team.import(row_hash,params[:id], options, teamtype)
        end

      rescue
        errors << $ERROR_INFO
        puts errors.to_s
      end

      elsif params[:model] == "ReviewResponseMap"
        contents_hash = eval(params[:contents_hash])
        @header_integrated_body = hash_rows_with_headers(contents_hash[:header],contents_hash[:body])
        errors = []

        begin
          @header_integrated_body.each do |row_hash|
            ReviewResponseMap.import(row_hash,session,params[:id])
          end

        rescue
          errors << $ERROR_INFO
          puts errors.to_s
        end
      elsif params[:model] == "MetareviewResponseMap"
        contents_hash = eval(params[:contents_hash])
        @header_integrated_body = hash_rows_with_headers(contents_hash[:header],contents_hash[:body])
        errors = []

        begin
          @header_integrated_body.each do |row_hash|
            MetareviewResponseMap.import(row_hash,session,params[:id])
          end

        rescue
          errors << $ERROR_INFO
          puts errors.to_s
        end
    elsif params[:model] == 'SignUpTopic'
      session[:assignment_id] = params[:id]
      contents_hash[:body].each do |row|
        SignUpTopic.import(row, session, params[:id])
      end

    else    # params[:model] = "User"
      contents_hash = eval(params[:contents_hash])

      if params[:has_header] == 'true'
        @header_integrated_body = hash_rows_with_headers(contents_hash[:header],contents_hash[:body])
      else
        new_header = [params[:select1], params[:select2], params[:select3]]
        @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
      end

      errors = []

      begin

        @header_integrated_body.each do |row_hash|
          User.import(row_hash, session)
        end

      rescue
        errors << $ERROR_INFO
        puts errors.to_s
      end
   end
    errors
  end

  protected


  # Produces an array, where each entry in the array is a hash.
  # The hash keys are the column titles, and the hash values are the associated values.
  # E.G. [ { :name => 'jsmith', :fullname => 'John Smith' , :email => 'jsmith@gmail.com' },
  #        { :name => 'jdoe', :fullname => 'Jane Doe', :email => 'jdoe@gmail.com' } ]
  def hash_rows_with_headers(header, body)

    new_body = []

    if params[:model] == "User"
      header.map! { |column_name| column_name.to_sym }

      body.each do |row|
        new_body << header.zip(row).to_h
      end

    elsif params[:model] == "AssignmentTeam" or params[:model] == "CourseTeam"
      header.map! { |column_name| column_name.to_sym }
      body.each do |row|
        h = Hash.new()
        if params[:has_teamname] == "true_first"
          h[header[0]] = row.shift
          h[header[1]] = row
        elsif params[:has_teamname] == "true_last"
          h[header[1]] = row.pop
          h[header[0]] = row
        else
          h[header[0]] = row
        end
        new_body << h
      end

    elsif params[:model] == "ReviewResponseMap"

      header.map! { |column_name| column_name.to_sym }
      body.each do |row|
        h = Hash.new()
        if params[:has_reviewee] == "true_first"
          h[header[0]] = row.shift
          h[header[1]] = row
        elsif params[:has_reviewee] == "true_last"
          h[header[1]] = row.pop
          h[header[0]] = row
        else
          h[header[0]] = row
        end
        new_body << h
      end

    elsif params[:model] == "MetareviewResponseMap"

      header.map! { |column_name| column_name.to_sym }
      body.each do |row|
        h = Hash.new()
        if params[:has_reviewee] == "true_first"
          h[header[0]] = row.shift
          h[header[1]] = row.shift
          h[header[2]] = row
        elsif params[:has_reviewee] == "true_last"
          h[header[2]] = row.pop
          h[header[1]] = row.pop
          h[header[0]] = row
        else
          h[header[0]] = row
        end
        new_body << h
      end
    end

    new_body
  end

  # Produces a hash where :header refers to the header (may be nil)
  # and :body refers to the contents of the file except the header.
  # :header is an array, and :body is a two-dimensional array.
  def parse_to_hash(import_grid, has_header)
    file_hash = Hash.new
    if has_header == 'true'
      file_hash[:header] = import_grid.shift
      file_hash[:body] = import_grid
    else
      file_hash[:header] = nil
      file_hash[:body] = import_grid
    end
    puts file_hash
    file_hash
  end

  # Produces a two-dimensional array.
  # The outer array contains "rows".
  # The inner arrays contain "elements of rows" or "columns".
  def parse_to_grid(contents, delimiter)
    contents_grid = []
    contents.each_line do |line|
      contents_grid << parse_line(line, delimiter)
    end
    contents_grid
  end

  def importFile(session, params)
    delimiter = get_delimiter(params)
    file = params['file'].try(:tempfile)

    errors = []
    first_row_read = false
    row_header = {}
    begin
      file.each_line do |line|
        line.chomp!
        if first_row_read == false # I don't like the logic here. The code in this if only need to run once. --Yang
          row_header = parse_line(line.downcase, delimiter)
          first_row_read = true
          if row_header.include?("email")
            # skip if first row contains header. In case of user information, it will contain name of user (mandatory
            next
          else
            row_header = {}
          end
        end
        next if line.empty?
        row = parse_line(line, delimiter)
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
      end
    rescue
      errors << $ERROR_INFO
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

  def parse_line(line, delimiter)
    items = if delimiter == ","
              line.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)
            else
              line.split(delimiter)
            end
    row = []
    items.each {|value| row << value.sub("\"", "").sub("\"", "").strip }
    row
  end

  # def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => Object.const_get(params[:model]).last.versions.last.id)}>undo</a>"
  # end
end
