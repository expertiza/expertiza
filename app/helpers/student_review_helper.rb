module StudentReviewHelper
  # Render topic row for bidding topic review
  def get_intelligent_review_row(topic, selected_topics, max_team_size = 3)
    row_html = ''
    if selected_topics.present?
      selected_topics.each do |selected_topic|
        row_html = if selected_topic.topic_id == topic
                     '<tr bgcolor="yellow">'
                   else
                     '<tr id="topic_' + topic.id.to_s + '">'
                   end
      end
    else
      row_html = '<tr id="topic_' + topic.id.to_s + '" style="background-color:' + get_topic_bg_color_by_reveiw(topic, max_team_size) + '">'
    end
    row_html.html_safe
  end

  def get_topic_bg_color_by_reveiw(topic, max_team_size)
    red = (400 * (1 - (Math.tanh(2 * [max_team_size.to_f / ReviewBid.where(topic_id: topic.id).count, 1].min - 1) + 1) / 2)).to_i.to_s
    green = (400 * (Math.tanh(2 * [max_team_size.to_f / ReviewBid.where(topic_id: topic.id).count, 1].min - 1) + 1) / 2).to_i.to_s
    'rgb(' + red + ',' + green + ',0)'
  end
end
