module DiffHelper

  class InputFile < Array

    attr_accessor :pointer

    def initialize
      self.pointer = 0
    end

    def current_line
      self[self.pointer]
    end

    def advance_pointer!
      self.pointer += 1
    end

    def find_current_line_in(other)
      index = (other[other.pointer..-1] || []).index(self.current_line)
      return index.nil? ? nil : other.pointer + index
    end
  end

  class OutputFile < Array

    class Line < String

      attr_accessor :type, :original_number


      def initialize(type, input_file)
        self.type = type
        return unless input_file
        self.replace(input_file.current_line)
        self.original_number = input_file.pointer + 1
        input_file.advance_pointer!
      end
    end

    def add_line(type, input_file = nil)
      self.push(Line.new(type, input_file))
    end
  end

  class Processor

    attr_accessor :absolute_line_num
    attr_accessor :first_file_array
    attr_accessor :second_file_array
    attr_accessor :comparison_array

    attr_accessor :source, :target
    attr_accessor :source_output, :target_output

    def initialize(source_file_name, target_file_name)
      @absolute_line_num = 0
      @first_file_array = []
      @second_file_array = []
      @comparison_array = []
      self.source = InputFile.new
      self.target = InputFile.new

      self.source_output = OutputFile.new
      self.target_output = OutputFile.new
      IO.readlines(source_file_name).each do |line|
        self.source << line
      end
      IO.readlines(target_file_name).each do |line|
        self.target << line
      end

      ##################################
      #source_file_name.each do |line|
      #self.source << line
      #end
      #target_file_name.each do |line|
      #self.target << line
      #end
      ##################################

    end

    def handle_exactly_matched

      #puts "##BEGIN-MATCH##"
      @absolute_line_num+=1
      #puts(@absolute_line_num)
      #puts source.current_line,target.current_line
      @first_file_array << source.current_line
      @second_file_array << target.current_line
      @comparison_array << "MATCH"
      source_output.add_line(:unchanged, source)
      target_output.add_line(:unchanged, target)
      #puts "##END##"
    end

    def handle_line_changed

      #puts "##BEGIN-CHANGED##"
      @absolute_line_num+=1
      #puts(@absolute_line_num)
      #puts source.current_line,target.current_line
      @first_file_array << source.current_line
      @second_file_array << target.current_line
      @comparison_array << "change"
      source_output.add_line(:changed, source)
      target_output.add_line(:changed, target)
      #puts "##END##"


    end

    def handle_block_added(size)

      #puts "##BEGIN-ADDED##"
      size.times do
        @absolute_line_num+=1
        #puts(@absolute_line_num)
        #puts source.current_line,target.current_line.gsub(/\n/," ")
        @first_file_array << "$"
        @second_file_array << target.current_line
        @comparison_array << "ADD"
        source_output.add_line(:added) # Empty line in the left side of the diff
        target_output.add_line(:added, target)
      end
      # puts "##END##"
    end

    def handle_block_deleted(size)

      #puts "#BEGIN-DELETED##"
      size.times do
        @absolute_line_num+=1
        #puts(@absolute_line_num)
        # puts source.current_line,target.current_line
        @first_file_array << source.current_line
        @second_file_array << "$"
        @comparison_array << "DELETE"
        source_output.add_line(:deleted, source)
        target_output.add_line(:deleted)  # Empty line in the right side of the diff
      end
      #puts "##ENDdeleted##"
    end

    def process!
      while ( source.pointer < source.size && target.pointer < target.size) do
        matched = source.find_current_line_in(target)
        if matched
          if (matched > target.pointer)
            deleted = target.find_current_line_in(source)
            handle_block_deleted(deleted - source.pointer) if deleted
          end
          handle_block_added(matched - target.pointer)
          handle_exactly_matched
        else
          found = target.find_current_line_in(source)
          if found
            handle_block_deleted(found - source.pointer)
          else
            handle_line_changed
          end
        end
      end

      handle_block_deleted(source.size - source.pointer)
      handle_block_added(target.size - target.pointer)

      return self
    end
  end

end


#processor = DiffHelper::Processor.new('left.txt', 'right.txt')
#
#
#DiffHelper::Formatter::Html.new(processor.process!, 'diff.html').format
#
#for i in (0..processor.absolute_line_num)
#  first =   processor.first_file_array[i].to_s
#  second = processor.second_file_array[i].to_s
#  third = processor.comparison_array[i]
#  first = first.gsub("\n","")
#  second = second.gsub("\n","")
#  #print " { "
#  print " i: ",i
#  print " FIRST:",first
#  print " SECOND: ",second
#  print "TYPE: ",third
#  #puts " }"
#  puts "\n"
#end
