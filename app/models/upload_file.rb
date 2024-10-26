class UploadFile < Question
  # This method returns what to display if an instructor (etc.) is creating or editing a itemnaire (itemnaires_controller.rb)
  def edit(_count)
    html = '<tr>'
    html += '<td align="center"><a rel="nofollow" data-method="delete" href="/items/' + id.to_s + '">Remove</a></td>'
    html += '<td><input size="6" value="' + seq.to_s + '" name="item[' + id.to_s + '][seq]" id="item_' + id.to_s + '_seq" type="text"></td>'
    html += '<td><textarea cols="50" rows="1" name="item[' + id.to_s + '][txt]" id="item_' + id.to_s + '_txt" placeholder="Edit item content here">' + txt + '</textarea></td>'
    html += '<td><input size="10" disabled="disabled" value="' + type + '" name="item[' + id.to_s + '][type]" id="item_' + id.to_s + '_type" type="text"></td>'
    html += '<td><!--placeholder (UploadFile does not need weight)--></td>'
    html += '</tr>'

    html.html_safe
  end

  # This method returns what to display if an instructor (etc.) is viewing a itemnaire
  def view_item_text
    html = '<TR><TD align="left"> ' + txt + ' </TD>'
    html += '<TD align="left">' + type + '</TD>'
    html += '<td align="center">' + weight.to_s + '</TD>'
    html += '<TD align="center">&mdash;</TD>'
    html += '</TR>'
    html.html_safe
  end

  def complete(count, answer = nil)
    # Use "app/views/submitted_content/_submitted_files.html.erb" partial.
  end

  def view_completed_item(count, files)
    # Use "display_directory_tree" method in "app/helpers/submitted_content_helper.rb"
  end
end
