module BookmarksHelper

  def self.find_tags(tags_array)
    @tags = Array.new
    for each_of_my_tag in tags_array
      this_tag_tuple= Tag.where(["tagname = ?",each_of_my_tag]).first
      unless this_tag_tuple.nil?
        @tags << this_tag_tuple
      else
      end
    end
    return @tags
  end

  def self.join_tags(my_tag_array)
    my_return_string = ""
    for each_tag in my_tag_array
      if(!my_return_string.empty?)
        my_return_string = my_return_string + ", "
      end
      my_return_string = my_return_string + each_tag
    end
    return my_return_string
  end

  def self.separate_tags( my_tag_string)
    my_return_array = Array.new
    temp_tags = my_tag_string.split(/,/)
    for b_tag in temp_tags
      b_tag1 = b_tag.lstrip
      b_tag2 = b_tag1.rstrip
      b_tag3 = b_tag2.downcase
      if b_tag3 != nil && !(b_tag3.empty?)
        my_return_array << b_tag3
      end
    end
    return my_return_array
  end

  def self.prepare_string(mystring)
    # For a given string remove all spaces to the left, right, and downcase all of it ...
    # ... sepcifically done to urls, and search tags
    b_tag1 = mystring.lstrip
    b_tag2 = b_tag1.rstrip
    b_tag3 = b_tag2.downcase
    return b_tag3
  end
end
