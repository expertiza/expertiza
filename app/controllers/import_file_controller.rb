class ImportFileController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_ta_privileges?
  end

  def show
    @id = params[:id]
    @model = params[:model]
    @options = params[:options]
    @delimiter = get_delimiter(params)
    @has_header = params[:has_header]
    @has_teamname = if @model == 'AssignmentTeam' || @model == 'CourseTeam'
                      params[:has_teamname]
                    else
                      'nil'
                    end
    @has_reviewee = (params[:has_reviewee] if @model == 'ReviewResponseMap')
    if @model == 'MetareviewResponseMap'
      @has_reviewee = params[:has_reviewee]
      @has_reviewer = params[:has_reviewer]
    else
      @has_reviewee = 'nil'
      @has_reviewer = 'nil'
    end
    if @model == 'SignUpTopic'
      @optional_count = 0
      @optional_count += 1 if params[:category] == 'true'
      @optional_count += 1 if params[:description] == 'true'
      @optional_count += 1 if params[:link] == 'true'
    else
      @optional_count = 0
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
    err_msg = 'The following errors were encountered during import.<br/>Other records may have been added. A second submission will not duplicate these records.<br/><ul>'
    errors.each do |error|
      err_msg = err_msg + '<li>' + error.to_s + '<br/>'
    end
    err_msg += '</ul>'
    if errors.empty?
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'The file has been successfully imported.', request)
      undo_link('The file has been successfully imported.')
    else
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].username, err_msg, request)
      flash[:error] = err_msg
    end
    redirect_to session[:return_to]
  end

  def import_from_hash(session, params)
    if (params[:model] == 'AssignmentTeam') || (params[:model] == 'CourseTeam')
      contents_hash = eval(params[:contents_hash])
      @header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
      errors = []
      begin
        @header_integrated_body.each do |row_hash|
          teamtype = if params[:model] == 'AssignmentTeam'
                       AssignmentTeam
                     else
                       CourseTeam
                     end
          options = JSON.parse(params[:options])
          options[:has_teamname] = params[:has_teamname]
          Team.import(row_hash, params[:id], options, teamtype)
        end
      rescue StandardError
        errors << $ERROR_INFO
      end
    elsif params[:model] == 'ReviewResponseMap'
      contents_hash = eval(params[:contents_hash])
      @header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
      errors = []
      begin
        @header_integrated_body.each do |row_hash|
          ReviewResponseMap.import(row_hash, session, params[:id])
        end
      rescue StandardError
        errors << $ERROR_INFO
      end
    elsif params[:model] == 'MetareviewResponseMap'
      contents_hash = eval(params[:contents_hash])
      @header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
      errors = []
      begin
        @header_integrated_body.each do |row_hash|
          MetareviewResponseMap.import(row_hash, session, params[:id])
        end
      rescue StandardError
        errors << $ERROR_INFO
      end
    elsif params[:model] == 'SignUpTopic' || params[:model] == 'SignUpSheet'
      contents_hash = eval(params[:contents_hash])
      if params[:has_header] == 'true'
        @header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
      else
        if params[:optional_count] == '0'
          new_header = [params[:select1], params[:select2], params[:select3]]
          @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
        elsif params[:optional_count] == '1'
          new_header = [params[:select1], params[:select2], params[:select3], params[:select4]]
          @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
        elsif params[:optional_count] == '2'
          new_header = [params[:select1], params[:select2], params[:select3], params[:select4], params[:select5]]
          @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
        elsif params[:optional_count] == '3'
          new_header = [params[:select1], params[:select2], params[:select3], params[:select4], params[:select5], params[:select6]]
          @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
        end
      end
      errors = []
      begin
        @header_integrated_body.each do |row_hash|
          session[:assignment_id] = params[:id]
          Object.const_get(params[:model]).import(row_hash, session, params[:id])
        end
      rescue StandardError
        errors << $ERROR_INFO
      end
    elsif params[:model] == 'AssignmentParticipant' || params[:model] == 'CourseParticipant'
      contents_hash = eval(params[:contents_hash])
      if params[:has_header] == 'true'
        @header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
      else
        new_header = [params[:select1], params[:select2], params[:select3], params[:select4]]
        @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
      end
      errors = []
      begin
        if params[:model] == 'AssignmentParticipant'
          @header_integrated_body.each do |row_hash|
            AssignmentParticipant.import(row_hash, session, params[:id])
          end
        elsif params[:model] == 'CourseParticipant'
          @header_integrated_body.each do |row_hash|
            CourseParticipant.import(row_hash, session, params[:id])
          end
        end
      rescue StandardError
        errors << $ERROR_INFO
      end
    else # params[:model] = "User"
      contents_hash = eval(params[:contents_hash])
      if params[:has_header] == 'true'
        @header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
      else
        new_header = [params[:select1], params[:select2], params[:select3]]
        @header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
      end
      errors = []
      begin
        @header_integrated_body.each do |row_hash|
          User.import(row_hash, nil, session)
        end
      rescue StandardError
        errors << $ERROR_INFO
      end
    end
    errors
  end

  protected

  # Produces an array, where each entry in the array is a hash.
  # The hash keys are the column titles, and the hash values are the associated values.
  #
  # E.G. [ { :name => 'jsmith', :fullname => 'John Smith' , :email => 'jsmith@gmail.com' },
  #        { :name => 'jdoe', :fullname => 'Jane Doe', :email => 'jdoe@gmail.com' } ]
  #
  def hash_rows_with_headers(header, body)
    new_body = []
    if (params[:model] == 'User') || (params[:model] == 'AssignmentParticipant') || (params[:model] == 'CourseParticipant') || (params[:model] == 'SignUpTopic')
      header.map! { |str| str.strip.downcase.gsub(/\s+/, "").to_sym }
      body.each do |row|
        new_body << header.zip(row).to_h
      end
    elsif (params[:model] == 'AssignmentTeam') || (params[:model] == 'CourseTeam')
      header.map!(&:to_sym)
      body.each do |row|
        h = {}
        if params[:has_teamname] == 'true_first'
          h[header[0]] = row.shift
          h[header[1]] = row
        elsif params[:has_teamname] == 'true_last'
          h[header[1]] = row.pop
          h[header[0]] = row
        else
          h[header[0]] = row
        end
        new_body << h
      end
    elsif params[:model] == 'ReviewResponseMap'
      header.map!(&:to_sym)
      body.each do |row|
        h = {}
        if params[:has_reviewee] == 'true_first'
          h[header[0]] = row.shift
          h[header[1]] = row
        elsif params[:has_reviewee] == 'true_last'
          h[header[1]] = row.pop
          h[header[0]] = row
        else
          h[header[0]] = row
        end
        new_body << h
      end
    elsif params[:model] == 'MetareviewResponseMap'
      header.map!(&:to_sym)
      body.each do |row|
        h = {}
        if params[:has_reviewee] == 'true_first'
          h[header[0]] = row.shift
          h[header[1]] = row.shift
          h[header[2]] = row
        elsif params[:has_reviewee] == 'true_last'
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
  #
  # E.G. { :header => ['name', 'fullname', 'email'],
  #        :body => [ ['jsmith', 'John Smith', 'jsmith@gmail.com'],
  #                   ['jdoe', 'Jane Doe', 'jdoe@gmail.com' ] ] }
  #
  def parse_to_hash(import_grid, has_header)
    file_hash = {}
    if has_header == 'true'
      file_hash[:header] = import_grid.shift
      file_hash[:body] = import_grid
    else
      file_hash[:header] = nil
      file_hash[:body] = import_grid
    end
    file_hash
  end

  # Produces a two-dimensional array.
  # The outer array contains "rows".
  # The inner arrays contain "elements of rows" or "columns".
  #
  # E.G. [ [ 'name', 'fullname', 'email' ],
  #        [ 'jsmith', 'John Smith', 'jsmith@gmail.com' ],
  #        [ 'jdoe', 'Jane Doe', 'jdoe@gmail.com' ] ]
  #
  def parse_to_grid(contents, delimiter)
    contents_grid = []
    contents.each_line do |line|
      contents_grid << parse_line(line, delimiter) unless line.strip == ''
    end
    contents_grid
  end

  def get_delimiter(params)
    delim_type = params[:delim_type]
    delimiter = case delim_type
                when 'comma' then ','
                when 'space' then ' '
                when 'tab' then "\t"
                when 'other' then params[:other_char]
                end
    delimiter
  end

  def parse_line(line, delimiter)
    items = if delimiter == ','
              line.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)
            else
              line.split(delimiter)
            end
    row = []
    items.each { |value| row << value.sub('"', '').sub('"', '').strip }
    row
  end

  # def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => Object.const_get(params[:model]).last.versions.last.id)}>undo</a>"
  # end
end
