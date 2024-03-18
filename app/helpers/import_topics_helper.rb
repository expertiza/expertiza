require 'csv'

module ImportTopicsHelper
  def self.define_attributes(row_hash)
    attributes = {}
    attributes['topic_identifier'] = row_hash[:topic_identifier].strip
    attributes['topic_name'] = row_hash[:topic_name].strip
    attributes['max_choosers'] = row_hash[:max_choosers].strip
    attributes['category'] = row_hash[:category].strip unless row_hash[:category].nil?
    attributes['description'] = row_hash[:description].strip unless row_hash[:description].nil?
    attributes['link'] = row_hash[:link].strip unless row_hash[:link].nil?
    attributes
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
    sign_up_topic.save
    # sign_up_topic
  end
end
