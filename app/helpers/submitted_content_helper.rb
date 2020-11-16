module SubmittedContentHelper
  require 'pstore'
  def display_directory_tree(participant, files, display_to_reviewer_flag)
    index = 0
    participant = @participant if @participant # TODO: Verify why this is needed
    assignment = participant.assignment # participant is @map.contributor
    topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id) # participant is @map.reviewer
    check_stage = assignment.get_current_stage(topic_id)

    ret = "\n<table id='file_table' cellspacing='5'>"
    ret += "\n   <tr><th>Name</th><th>Size</th><th>Type</th><th>Date Modified</th></tr>"
    for file in files
      begin
        ret += "\n   <tr>"
        ret += "\n   <td valign = top>\n      "
        ret += if check_stage != "Complete" && display_to_reviewer_flag == false
                 "<input type=radio id='chk_files' name='chk_files' value='#{index}'>"
               else
                 "<b>-</b>&nbsp"
               end
        ret += "\n      <input type=hidden id='filenames_#{index}' name='filenames[#{index}]' value='#{File.basename(file)}'>"
        ret += "\n      <input type=hidden id='directories_#{index}' name='directories[#{index}]' value='#{File.dirname(file)}'>"

        if File.exist?(file) && File.directory?(file)
          ret += link_to File.basename(file), :controller => 'submitted_content', :action => 'edit', :id => participant.id, "current_folder[name]" => file
        else
          ret += "\n      "
          # ret += link_to File.basename(file), :controller => 'submitted_content',
          #                                     :action => 'download',
          #                                     :id => participant.id,
          #                                     :download => File.basename(file),
          #                                     "current_folder[name]" => File.dirname(file)
          ret += link_to File.basename(file), {:controller => 'submitted_content', :action => 'download', :id => participant.id, :download => File.basename(file), "current_folder[name]" => File.dirname(file)}, :class => "fileLink", :download => File.basename(file).to_s
        end
        ret += "\n   </td>\n   <td valign = top>\n"
        ret += File.size(file).to_s
        ret += "\n   </td>\n   <td valign = top>\n"
        ret += File.ftype(file)
        ret += "\n   </td>\n   <td valign = top>\n"
        ret += File.mtime(file).to_s
        ret += "\n   </td>\n   </tr>"
        index += 1
      rescue StandardError
      end
    end
    ret += "\n</table><br/>"
    ret
  end

  # Zhewei: this method is used to display reviewer uploaded files during peer review.
  def display_review_files_directory_tree(participant, files)
    index = 0
    participant = @participant if @participant # TODO: Verify why this is needed
    assignment = participant.assignment # participant is @map.contributor
    html = ''

    for file in files
      begin
        if File.exist?(file)
          html += link_to image_tag('/assets/tree_view/List-submisstions-24.png'),
                          :controller => 'submitted_content',
                          :action => 'download',
                          :id => participant.id,
                          :download => File.basename(file),
                          "current_folder[name]" => File.dirname(file)
        end
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
    end
    html
  end

  def display_hyperlink_in_peer_review_question(comments)
    html = ''
    html += link_to image_tag('/assets/tree_view/List-hyperlinks-24.png'), comments, target: '_blank'
  end

  def list_sub_directories(file, participant)
    index = 0
    ret = "<ul id= 'subdir." + index.to_s + "." + index.to_s + "'>"
    Dir.foreach(file) do |path|
      next if path == "." or path == ".." or path == ".svn"
      index += 1
      disp = file + "/" + path
      display = File.basename(file) + "/" + path
      ret += "<li>"
      ret += "<input type=radio id='chk_files' name='chk_files' value='#{index}'>" if @check_stage != "Complete" && @flag == false
      ret += "<input type=hidden id='filenames_#{index}' name='filenames[#{index}]' value='" + File.dirname(disp) + "/" + File.basename(path) + "'>"
      if File.ftype(disp) == "directory"
        ret += "<a title='Expand/Collapse' href='#' onclick='javascript:collapseSubDirectory(#{index}); return false;'><img id='expand.#{index}' alt='Expand/Collapse' title='Expand/Collapse' src='/assets/up.png'></a>&nbsp;"
        ret += link_to path, :controller => 'submitted_content', :action => 'edit', :id => participant.id, :download => File.basename(path), "current_folder[name]" => File.dirname(disp)
        ret += "</li>"
        ret += list_sub_directories(disp, participant)
      else
        ret += link_to path, :controller => 'submitted_content', :action => 'edit', :id => participant.id, :download => File.basename(path), "current_folder[name]" => File.dirname(disp)
        ret += "</li>"
      end
    end
    ret += "</ul>"
  end

  # Installing RubyZip
  # run the command,  gem install rubyzip
  # restart the server
  def self.unzip_file(file_name, unzip_dir, should_delete)
    # begin
    Zip::File.open(file_name) do |zf|
      zf.each do |e|
        safename = FileHelper.sanitize_filename(e.name)
        fpath = File.join(unzip_dir, safename)
        FileUtils.mkdir_p(File.dirname(fpath))
        zf.extract(e, fpath)
      end
    end

    if should_delete
      # The zip file is no longer needed, so delete it
      File.delete(file_name)
    end
  # rescue
  # end
end

  #Holds information related to a link pressed during a review
  class LocalSubmittedContent
    attr_accessor :map_id, :round, :link , :start_at, :end_at, :created_at, :updated_at

    def initialize(**args)
      @map_id = args.fetch(:map_id,nil)
      @round = args.fetch(:round,nil)
      @link = args.fetch(:link,nil)
      @start_at = args.fetch(:start_at,nil)
      @end_at = args.fetch(:end_at,nil)
      @created_at = args.fetch(:created_at,nil)
      @updated_at = args.fetch(:updated_at,nil)
    end

    def initialize(args)
      @map_id = args.fetch(:map_id,nil)
      @round = args.fetch(:round,nil)
      @link = args.fetch(:link,nil)
      @start_at = args.fetch(:start_at,nil)
      @end_at = args.fetch(:end_at,nil)
      @created_at = args.fetch(:created_at,nil)
      @updated_at = args.fetch(:updated_at,nil)
    end

    #Turns a LocalSubmittedContent object into a hash
    def to_h()
        return {map_id: @map_id, round: @round, link: @link, start_at: @start_at, end_at: @end_at, created_at: @created_at, updated_at: @updated_at}
    end

    def ==(other)
      return @map_id = other.map_id && @round == other.round && @link == other.link &&
      @start_at == other.start_at && @end_at == other.end_at &&
      @created_at == other.created_at && @updated_at == other.updated_at
    end

  end

  #LocalStorage implementation using PStore
  class LocalStorage

    def initialize()
      @registry = []
      @pstore = PStore.new("local_submitted_content.pstore")
      @pstore.transaction do
        @pstore[:registry] ||= []
      end
      @registry = read()
    end

    #saves an instance of LocalSubmittedContent to pstore file and pushes to registry list
    def save(instance)
        @pstore.transaction do
          @registry << instance
          @pstore[:registry] = @registry
        end
    end

    #Ensures the registry list and pstore file always have the same instances
    def sync()
      @pstore.transaction do
        @pstore[:registry] = @registry
      end
    end

    # Find all entries that meet every field in the params hash
    # return list of matching entries 
    def where(params)
        found = []

        @registry.each do |item|
          if item.to_h().values_at(*params.keys) == params.values
            found << item
          end
        end
        return found
    end


    # Reads and returns data from Pstore registry
    def read()
      @pstore.transaction do 
        return @pstore[:registry]
      end
    end

    # Actually saves into the database
    def hard_save(instance)
        return SubmissionViewingEvent.create(instance.to_h())
    end

    # Actually saves all instances in registry list to database
    def hard_save_all()
      @registry.each do |item|
        SubmissionViewingEvent.create(item.to_h())
      end
    end

    #Removes instance from registry list then syncs to update pstore file
    def remove(instance)
      @registry.each_with_index do |item,i|
        if item.to_h() == instance.to_h()
          @registry.delete_at(i)
        end
      end
      sync()
    end

    #Clears registry and PStore file
    def remove_all()
      @registry = []
      sync()
    end

  end

end
