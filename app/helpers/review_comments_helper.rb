module ReviewCommentsHelper

  def self.construct_comments_table(comment_array)
    return "" unless comment_array.length > 0

    comment_window_html = "<table width='100%' cellpadding='3' style='table-layout: fixed; word-wrap: break-word;'>"
    for i in 0..(comment_array.length-1) do
      comment_window_html += "<tr><td><b>Comment #{i+1}:</b><br/>" +
          comment_array[i].to_s + "</td></tr>"
    end
    comment_window_html += "</table>"
    return comment_window_html
  end


end
