class ImportFileController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  def start
    @id = params[:id]
    @model = params[:model]
    @title = params[:title]
    @required_fields = @model.constantize.required_import_fields
    @optional_fields = @model.constantize.optional_import_fields(@id)
    @import_options = @model.constantize.import_options
  end

  def show
    @id = params[:id]
    @model = params[:model]
    @has_header = params[:has_header]
    @options = params[:options]
    delimiter = get_delimiter(params)

    # All required fields are selected by default
    @selected_fields = @model.constantize.required_import_fields
    # Add the chosen optional fields from start
    optional_fields = @model.constantize.optional_import_fields(@id)
    optional_fields.each do |field, display|
      if params[field] == "true"
        @selected_fields.store(field, display)
      end
    end
    @field_count = @selected_fields.length

    # Read the file
    @current_file = params[:file]
    contents_grid = parse_to_grid(@current_file.read, delimiter)
    @contents_hash = parse_to_hash(contents_grid, params[:has_header])
  end

  def import
    errors = import_from_hash(session, params)
    err_msg = "The following errors were encountered during import.<br/>Other records may have been added. A second submission will not duplicate these records.<br/><ul>"
    errors.each do |error|
      err_msg = err_msg + "<li>" + error.to_s + "<br/>"
    end
    err_msg += "</ul>"
    if errors.empty?
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "The file has been successfully imported.", request)
      undo_link("The file has been successfully imported.")
    else
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, err_msg, request)
      flash[:error] = err_msg
    end
    redirect_to session[:return_to]
  end

  # NOTE: Optional columns currently handled with a checkbox in the show that carries into the
  # import function (after the table appears). Will need to modify for the advice. Should probably
  # require files to have a header, this will simplify the inclusion of the question advice.
  #
  # Also, good way to refactor this in general? Without a header, pass the expected params to the show
  # view. Update the expected columns view in the start page to reflect the optional params.
  def import_from_hash(session, params)
    model = params[:model]
    contents_hash = eval(params[:contents_hash])

    if params[:has_header] == "true"
      header_integrated_body = hash_rows_with_headers(contents_hash[:header], contents_hash[:body])
    else
      # If there is no header, recover the selected fields in the select* params
      new_header = []
      params.each_pair do |p, value|
        if p.match(/\Aselect/)
          new_header << params[p]
        end
      end
      header_integrated_body = hash_rows_with_headers(new_header, contents_hash[:body])
    end

    # Call ::import for each row of the file
    errors = []
    begin
      header_integrated_body.each do |row_hash|
        if model.constantize.import_options.empty?
          model.constantize.import(row_hash, session, params[:id])
        else
          model.constantize.import(row_hash, session, params[:id], params[:options])
        end
      end
    rescue
      errors << $ERROR_INFO
    end
    errors
  end

  protected

  # Produces an array, where each entry in the array is a hash.
  # The hash keys are the column titles, and the hash values are the associated values.
  #
  # E.G. [ { :name => 'jsmith', :fullname => 'John Smith' , :email => 'jsmith@gmail.com' },
  #        { :name => 'jdoe', :fullname => 'Jane Doe', :email => 'jdoe@gmail.com' } ]
  def hash_rows_with_headers(header, body)
    new_body = []
    header.map! { |column_name| column_name.to_sym }
    body.each do |row|
      new_body << header.zip(row).to_h
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
    file_hash = Hash.new
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
      contents_grid << parse_line(line, delimiter) unless line.strip == ""
    end
    contents_grid
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
              line.scan(/(?:[^#{delimiter}\"]|\"[^\"]*\")+/).map { |item| item.gsub(/\"/, '') }
            end
    row = []
    items.each {|value| row << value.sub("\"", "").sub("\"", "").strip }
    row
  end
end
