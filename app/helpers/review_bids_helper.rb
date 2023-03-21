module ReviewBidsHelper
  # renders the topic row for the topics table
  # in review_bids/show.html.erb
  def get_intelligent_topic_row_review_bids(topic, selected_topics, num_participants)
    row_html = ''
    if selected_topics.present?
      selected_topics.each do |selected_topic|
        row_html = if (selected_topic.topic_id == topic.id) && !selected_topic.is_waitlisted
                     '<tr bgcolor="yellow">'
                   elsif (selected_topic.topic_id == topic.id) && selected_topic.is_waitlisted
                     '<tr bgcolor="lightgray">'
                   else
                     '<tr id="topic_' + topic.id.to_s + '">'
                   end
      end
    else
      row_html = '<tr id="topic_' + topic.id.to_s + '" style="background-color:' + get_topic_bg_color_review_bids(topic, num_participants) + '">'
    end
    row_html.html_safe
  end

  # gets the background color with respect to number of participants and bid size
  # in review_bids/show.html.erb
  def get_topic_bg_color_review_bids(topic, num_participants)
    num_bids = ReviewBid.where(signuptopic_id: topic.id).count.to_f
    green = (400 * (1 - (Math.tanh(2 * (num_bids / num_participants.to_f) - 1) + 1) / 2)).to_i.to_s
    red = (400 * (Math.tanh(2 * (num_bids / num_participants.to_f) - 1) + 1) / 2).to_i.to_s
    'rgb(' + red + ',' + green + ',0)'
  end
end
