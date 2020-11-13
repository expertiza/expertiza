module ReviewBidsHelper

	#renders the topic row for the topics table
	#in review_bids/show.html.erb
	def get_intelligent_topic_row_review_bids(topic, selected_topics, num_participants)
    row_html = ''
    if selected_topics.present?
      selected_topics.each do |selected_topic|
        row_html = if selected_topic.topic_id == topic.id and !selected_topic.is_waitlisted
                     '<tr bgcolor="yellow">'
                   elsif selected_topic.topic_id == topic.id and selected_topic.is_waitlisted
                     '<tr bgcolor="lightgray">'
                   else
                     '<tr id="topic_' + topic.id.to_s + '">'
                   end
      end
    else
      row_html = '<tr id="topic_' + topic.id.to_s + '" style="background-color:' + get_topic_bg_color_review_bid(topic, num_participants) + '">'
    end
    row_html.html_safe
  end

  #renders the topic row for the selections table
  #in review_bids/show.html.erb
  def get_topic_bg_color_review_bids(topic, num_participants)
    red = (400 * (1 - (Math.tanh(2 * (ReviewBid.where(signuptopic_id:topic.id).count.to_f/num_participants.to_f) - 1) + 1) / 2)).to_i.to_s
    green = (400 * (Math.tanh(2 * (ReviewBid.where(signuptopic_id:topic.id).count.to_f/num_participants.to_f) - 1) + 1) / 2).to_i.to_s
    'rgb(' + red + ',' + green + ',0)'
  end

end