class ReviewFile < ActiveRecord::Base
  # Associate the author (participant) with the file
  belongs_to :participant, :class_name => 'Participant',
             :foreign_key => 'author_participant_id'

  # Associate the review_comments with the review_file
  has_many :review_comments, :class_name => 'ReviewComment',
           :foreign_key => 'review_file_id'


  #attr_accessor :filepath, :author_participant_id, :version_number

  # Returns the version_number of the collectively most recent version of code
  #   review files submitted by participant (and all members by the team if any)
  def self.get_max_version_num(participant)
    # Find the max version number of code submitted by 'participant'
    file = ReviewFile.find(
        :first, :conditions => ['author_participant_id = ?', participant.id],
        :order => 'version_number desc')
    #if file
    #  max_version_num = file.version_number
    #else
    #  max_version_num = 0
    #end
    max_version_num = file.nil? ? 0 : file.version_number


    # For all other members of the team, find the most recent version of code
    #   review files submitted by any of them.
    if participant.assignment.team_assignment
      participant.team.get_participants.each { |member|
        file = ReviewFile.find(
            :first, :conditions => ['author_participant_id = ?', member.id],
            :order => 'version_number desc')

        #if file
        #  max_member_version = file.version_number
        #else
        #  max_member_version = 0
        #end

        max_member_version  = file.nil? ? 0 : file.version_number

        max_version_num = max_member_version if max_member_version > max_version_num
      }
    end
    puts max_version_num
    return max_version_num
  end
  def self.get_offset_array(file_contents)

    offset_array = [0]
    for i in (1..file_contents.length)
      offset_array << (offset_array[i-1] + file_contents[i-1].size-1)
    end
    return offset_array
  end

  def self.swap_files(older_file, newer_file)
    @files = Hash.new
    if older_file.version_number > newer_file.version_number
      temp = older_file
      @older_file = newer_file
      @newer_file = temp
      @files = {:@newer_file => older_file, :@older_file => newer_file}

    else
      @files = {:@newer_file => newer_file, :@older_file => older_file}
    end

    return @files
  end

  def self.get_first_file_array(processor, i)
    if(processor.first_file_array[i] != nil)
      processor.first_file_array[i] = processor.first_file_array[i].chomp
    end
    return processor
  end

  def self.get_second_file_array(processor, i)
    if(processor.second_file_array[i] != nil)
      processor.second_file_array[i] = processor.second_file_array[i].chomp
    end
    return processor
  end


  #Returns the non empty lines in the code file to be displayed on the right #
  def self.getHighlightCellRight(newer_version_comments,second_offset,second_line_num)
    @highlight_cell_right_file = Hash.new
    newer_version_comments.each do |each_comment|
      line_counter = each_comment.initial_line_number
      while line_counter <= each_comment.last_line_number do
        #--------------------------CHANGE----------------------------@NIMITT


        table_row_num =  line_counter
        table_row_num = @second_offset.length + 1 unless table_row_num

        # Increment table_row_num until a non "" string is encountered in @first_line_num
        while ( (@second_line_num[table_row_num].nil? or
            @second_line_num[table_row_num].blank?) and
            table_row_num < @second_line_num.length)
          table_row_num += 1
        end

        @highlight_cell_right_file[table_row_num] = true
        line_counter = line_counter + 1
      end
    end

    return   @highlight_cell_right_file
  end


  def self.get_first_line_num(processor, i, first_count)

    hash = Hash.new
    first = processor.first_file_array[i].to_s
    @first_line_num = []
    if(first != "")
      #@first_line_num << first_count+1
      #first_count += 1
      hash = {:@first_line_num => first_count + 1, :first_count => first_count += 1}
    else # empty
         #  @first_line_num << nil
      hash = {:@first_line_num => nil, :first_count => first_count}
    end
  end

  def self.get_second_line_num(processor, i, second_count)

    hash2 = Hash.new
    second = processor.second_file_array[i].to_s
    @second_line_num = []
    if(second != "")
      #  @second_line_num << second_count+1
      #  second_count += 1
      hash2 = {:@second_line_num => second_count + 1, :second_count => second_count += 1}
    else # empty
         #  @second_line_num << nil
      hash2 = {:@second_line_num => nil, :second_count => second_count}
    end
    return hash2
  end

  def self.get_first_offset(processor, i, first_offset)
    if i > 0
      first_offset << (first_offset[i-1]  + processor.first_file_array[i-1].size)
    end
    return first_offset
  end

  def self.get_second_offset(processor, i, second_offset)
    if i > 0
      second_offset << (second_offset[i-1]  + processor.second_file_array[i-1].size)
    end
    return second_offset
  end


  # Returns row in the ReviewFile table that has a filepath equal to one
  #   computed by the concatenation of this method's arguments.
  def self.get_file(code_review_dir, version_number, base_file_name)
    filepath = code_review_dir + ReviewFilesHelper::VERSION_DIR_SUFFIX +
               version_number.to_s + '//' + base_file_name
    return filepath
    #ReviewFile.find_by_filepath(filepath)

  end


#Returns the non empty lines in the code file to be displayed on the left #
  def self.getHighlightCellLeft(older_version_comments,first_offset,first_line_num)
    @highlight_cell_left_file = Hash.new
    older_version_comments.each do |each_comment|
      line_counter = each_comment.initial_line_number
      while line_counter <= each_comment.last_line_number do
      #--------------------------CHANGE----------------------------@NIMITT


        table_row_num =  line_counter
        table_row_num = first_offset.length + 1 unless table_row_num

        # Increment table_row_num until a non "" string is encountered in @first_line_num
        while ( (first_line_num[table_row_num].nil? or
            first_line_num[table_row_num].blank?) and
            table_row_num < first_line_num.length)
          table_row_num += 1
        end

        @highlight_cell_left_file[table_row_num] = true
        line_counter = line_counter + 1
      end
    end
    return  @highlight_cell_left_file
  end

  # Refactoring done to place remove the highlight right cell code from controller
  def self.highlightRightOffset(newer_version_comments,offset_array,file_contents)
  @highlight_cell_right_file = Hash.new
  newer_version_comments.each do |each_comment|
    line_counter = each_comment.initial_line_number
    while line_counter <= each_comment.last_line_number do
#--------------------------CHANGE----------------------------@NIMITT


      table_row_num =  line_counter
      table_row_num = offset_array.length + 1 unless table_row_num

      # Increment table_row_num until a non "" string is encountered in @first_line_num
      while ( (file_contents[table_row_num].nil? or
          file_contents[table_row_num].blank?) and
          table_row_num < file_contents.length)
        table_row_num += 1
      end

      @highlight_cell_right_file[table_row_num] = true
      line_counter = line_counter + 1
    end
  end
    return @highlight_cell_right_file
end


end
