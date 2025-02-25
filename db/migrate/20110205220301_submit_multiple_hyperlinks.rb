require 'yaml'

class SubmitMultipleHyperlinks < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :participants, :submitted_hyperlink, :submitted_hyperlinks
    Participant.find_each do |p|
      unless p.submitted_hyperlinks.nil?
        one_hyperlink = p.submitted_hyperlinks.strip
        if one_hyperlink.empty?
          # This means that for some reason an empty hyperlink was stored
          # then we will just change it to nil
          p.update_attribute :submitted_hyperlinks, nil
        else
          p.update_attribute :submitted_hyperlinks, YAML.dump([one_hyperlink])
        end
      end
    end
  end

  # Becareful when downgrading the database, because at this point there might
  # be many multiple links values that are going to be converted to a space
  # sparated string
  def self.down
    Participant.find_each do |p|
      unless p.submitted_hyperlinks.nil?
        multiple_hyperlinks = YAML.safe_load(p.submitted_hyperlinks).join(' ')
        p.update_attribute :submitted_hyperlinks, multiple_hyperlinks
      end
    end

    rename_column :participants, :submitted_hyperlinks, :submitted_hyperlink
  end
end
