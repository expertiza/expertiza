require 'csv'

module ImportTopicsHelper
  def self.define_attributes(columns)
    attributes = {}
    attributes["topic_identifier"] = columns[0].strip
    attributes["topic_name"] = columns[1].strip
    attributes["max_choosers"] = columns[2].strip
    attributes["category"] = columns[3].strip if columns.length > 3
    attributes
  end

  def self.create_new_sign_up_topic(attributes, session)
    sign_up_topic = SignUpTopic.new(attributes)
    sign_up_topic.assignment_id = session[:assignment_id]
    sign_up_topic.save
    # sign_up_topic
  end
end
