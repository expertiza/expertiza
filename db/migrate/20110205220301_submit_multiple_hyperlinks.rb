require 'yaml'

class SubmitMultipleHyperlinks < ActiveRecord::Migration
  def self.up
    rename_column :participants, :submitted_hyperlink, :submitted_hyperlinks

    puts "[Converting to YAML] Please wait, this could take some seconds..."

    Participant.find(:all).each do |p|
      unless p.submitted_hyperlinks.nil?
        one_hyperlink = p.submitted_hyperlinks.strip
        if one_hyperlink.empty?
          # This means that for some reason an empty hyperlink was stored
          # then we will just change it to nil
          p.update_attribute :submitted_hyperlinks, nil
        else
          p.update_attribute :submitted_hyperlinks, YAML::dump([one_hyperlink])
        end
      end
    end
    
    puts "[Converting to YAML] Done"
  end

  # Becareful when downgrading the database, because at this point there might
  # be many multiple links values that are going to be converted to a space 
  # sparated string
  def self.down
    puts "Becareful when downgrading submitted_hyperlinks, please read 20110205220301_submit_multiple_hyperlinks.rb"
    
    Participant.find(:all).each do |p|
      unless p.submitted_hyperlinks.nil?
        multiple_hyperlinks = YAML::load(p.submitted_hyperlinks).join(' ')
        p.update_attribute :submitted_hyperlinks, multiple_hyperlinks
      end
    end

    rename_column :participants, :submitted_hyperlinks, :submitted_hyperlink
  end
end
