require 'csv'

module ImportTopicsHelper

  def self.define_attributes(row_hash)
    attributes = {}
    if !row_hash[:description].nil? and !row_hash[:description].ascii_only?
      row_hash[:description] = self.trim_non_ascii(row_hash[:description])
    end
    attributes["topic_identifier"] = row_hash[:topic_identifier].strip
    attributes["topic_name"] = row_hash[:topic_name].strip
    attributes["max_choosers"] = row_hash[:max_choosers].strip
    attributes["category"] = row_hash[:category].strip unless row_hash[:category].nil?
    attributes["description"] = row_hash[:description].strip unless row_hash[:description].nil?
    attributes["link"] = row_hash[:link].strip unless row_hash[:link].nil?
    attributes
  end

  def self.trim_non_ascii(string)
    string.split('').each do |char|
      !char.ascii_only? ? string.tr!(char, ' ') : nil
    end
    string.gsub!(/\s+/, ' ')
  end

  # The old method is commented out below.
  # The define_attributes and define_attributes_extra methods were merged.
  #
  # def self.define_attributes(columns)
  #   attributes = {}
  #   attributes["topic_identifier"] = columns[0].strip
  #   attributes["topic_name"] = columns[1].strip
  #   attributes["max_choosers"] = columns[2].strip
  #   define_attributes_extra(attributes, columns)
  #   attributes
  # end

  # The old method is commented out below.
  # The define_attributes and define_attributes_extra methods were merged.
  #
  # def self.define_attributes_extra(attributes, columns)
  #   attributes["category"] = columns[3].strip if columns.length > 3
  #   attributes["description"] = columns[4].strip if columns.length > 4
  #   attributes["link"] = columns[5].strip if columns.length > 5
  #   attributes
  # end

  def self.create_new_sign_up_topic(attributes, session)
    sign_up_topic = SignUpTopic.new(attributes)
    sign_up_topic.assignment_id = session[:assignment_id]
    sign_up_topic.save!
    sign_up_topic.id
  end


  def self.assign_team_topic(topic_id, assigned_team)
    attributes = {}
    attributes["topic_id"] = topic_id
    attributes["team_id"] = assigned_team
    assign_team = SignedUpTeam.new(attributes)
    assign_team.save!
  end

end
