# This module contains all methods that are used to work on the submissions made by a participant.Right now, a participant can submit
# hyperlinks and files. In future this could be extended to contain submissions of wiki pages.

module Artifact
# Note: This method is not used yet. It is here in the case it will be needed.# @exception  If the index does not exist in the arraydef remove_hyperlink(index)
def remove_hyperlink(index)
  hyperlinks = get_hyperlinks
  raise "The link does not exist" unless index < hyperlinks.size

  hyperlinks.delete_at(index)
  self.submitted_hyperlinks = hyperlinks.empty? ? nil : YAML::dump(hyperlinks)
  #self.submitted_hyperlinks = hyperlinks.empty? ? nil : hyperlinks
  self.save
end

# Appends the hyperlink to a list that is stored in YAML format in the DB
# @exception  If is hyperlink was already there
#             If it is an invalid URL
def submit_hyperlink(hyperlink)
  hyperlink.strip!
  raise "The hyperlink cannot be empty" if hyperlink.empty?

  url = URI.parse(hyperlink)

  # If not a valid URL, it will throw an exception
  Net::HTTP.start(url.host, url.port)

  hyperlinks = get_hyperlinks_array

  hyperlinks << hyperlink
  self.submitted_hyperlinks = YAML::dump(hyperlinks)

  self.save
end

def get_submitted_files()
  files = Array.new
  if (self.directory_num)
    files = get_files(self.get_path)
  end
  return files
end

#private
# Use submit_hyperlink(), remove_hyperlink() instead
def submitted_hyperlinks=(val)
  write_attribute :submitted_hyperlinks, val
end

# TODO:REFACTOR: This shouldn't be handled using an if statement, but using
  # polymorphism for individual and team participants
  def get_hyperlinks
    if self.team
      links = self.team.get_hyperlinks
    else
      links = get_hyperlinks_array
    end

    return links
  end

  def get_hyperlinks_array
    self.submitted_hyperlinks.nil? ? [] : YAML::load(self.submitted_hyperlinks)
  end

  def get_files(directory)
    files_list = Dir[directory + "/*"]
    files = Array.new
    for file in files_list
      if File.directory?(file) then
        dir_files = get_files(file)
        dir_files.each { |f| files << f }
      end
      files << file
    end
    return files
  end
end
