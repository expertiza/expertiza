module StudentReviewHelper
  # Render topic row for bidding topic review
  # def get_intelligent_review_row(biditem,selected_topics)
  #   row_html = ''
  #   if selected_topics.present?
  #     selected_topics.each do |selected_topic|
  #       row_html = if(selected_topic.bid_topic_identifier == biditem.bid_topic_identifier)
  #                    '<tr id="topic_' + biditem[:team_id].to_s + '">'
  #                  end
  #     end
  #   else
  #       row_html = '<tr id="topic_' + biditem[:team_id].to_s + '" style="background-color:rbg(47, 352, 0)">'
  #   end
  #   row_html.html_safe
  # end

  def get_intelligent_review_row(bid, max_team_size = 3)
    row_html = ''
      row_html = '<tr id="topic_' + bid.id.to_s + '" style="background-color:' + get_topic_bg_color_by_review(bid, max_team_size) + '">'
    row_html.html_safe
  end

  def get_topic_bg_color_by_review(bid, max_team_size)
    red = (400 * (1 - (Math.tanh(2 * [max_team_size.to_f / Bid.where(topic_id: bid.id).count, 1].min - 1) + 1) / 2)).to_i.to_s
    green = (400 * (Math.tanh(2 * [max_team_size.to_f / Bid.where(topic_id: bid.id).count, 1].min - 1) + 1) / 2).to_i.to_s
    'rgb(' + red + ',' + green + ',0)'
  end

end
