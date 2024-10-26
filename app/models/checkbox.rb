class Checkbox < UnscoredQuestion
  include ActionView::Helpers
  # This method returns what to display if an instructor (etc.) is creating or editing a itemnaire (itemnaires_controller.rb)
  def edit(count)
    html = edit_remove_button(count) + edit_seq(count) + edit_item(count)
    html += edit_type(count) + edit_weight(count)
    safe_join(['<tr>'.html_safe, '</tr>'.html_safe], html.html_safe)
  end

  def edit_remove_button(_count)
    html = '<td align="center"><a rel="nofollow" data-method="delete" href="/items/'
    html += id.to_s + '">Remove</a></td>'
    html
  end

  def edit_seq(_count)
    html = '<td><input size="6" value="' + seq.to_s + '" name="item['
    html += id.to_s + '][seq]" id="item_' + id.to_s + '_seq" type="text"></td>'
    html
  end

  def edit_item(_count)
    html = '<td><textarea cols="50" rows="1" name="item[' + id.to_s + '][txt]" id="item_'
    html += id.to_s + '_txt" placeholder="Edit item content here">' + txt + '</textarea></td>'
    html
  end

  def edit_type(_count)
    html = '<td><input size="10" disabled="disabled" value="' + type + '" name="item['
    html += id.to_s + '][type]" id="item_' + id.to_s + '_type" type="text"></td>'
    html
  end

  def edit_weight(_count)
    html = '<td><!--placeholder (UnscoredQuestion does not need weight)--></td>'
    html
  end

  # This method returns what to display if an instructor (etc.) is viewing a itemnaire
  def view_item_text
    html = '<TR><TD align="left"> ' + txt + ' </TD>'
    html += '<TD align="left">' + type + '</TD>'
    html += '<td align="center">' + weight.to_s + '</TD>'
    html += '<TD align="center">Checked/Unchecked</TD>'
    html += '</TR>'
    safe_join([''.html_safe, ''.html_safe], html.html_safe)
  end

  def complete(count, answer = nil)
    html = check_previous_item + complete_first_second_input(count, answer)
    html += complete_third_input(count, answer)
    html += '<label for="responses_' + count.to_s + '">&nbsp;&nbsp;' + txt + '</label>'
    html += complete_script(count)
    html += complete_if_column_header
    safe_join([''.html_safe, ''.html_safe], html.html_safe)
  end

  def check_previous_item
    curr_item = Question.find(id)
    prev_item = Question.where('seq < ?', curr_item.seq).order(:seq).last
    html = if prev_item.type == 'ColumnHeader'
             '<td style="padding: 15px;">'
           else
             ''
           end
    html
  end

  def complete_first_second_input(count, answer = nil)
    html = '<input id="responses_' + count.to_s + '_comments" name="responses[' + count.to_s + '][comment]" type="hidden" value="">'
    html += '<input id="responses_' + count.to_s + '_score" name="responses[' + count.to_s + '][score]" type="hidden"'
    html += if !answer.nil? && (answer.answer == 1)
              'value="1"'
            else
              'value="0"'
            end
    html += '>'
    html
  end

  def complete_third_input(count, answer = nil)
    html = '<input id="responses_' + count.to_s + '_checkbox" type="checkbox" onchange="checkbox' + count.to_s + 'Changed()"'
    html += 'checked="checked"' if !answer.nil? && (answer.answer == 1)
    html += '>'

    html
  end

  def complete_script(count)
    html = '<script>function checkbox' + count.to_s + 'Changed() {'
    html += ' var checkbox = jQuery("#responses_' + count.to_s + '_checkbox");'
    html += ' var response_score = jQuery("#responses_' + count.to_s + '_score");'
    html += 'if (checkbox.is(":checked")) {'
    html += 'response_score.val("1");'
    html += '} else {'
    html += 'response_score.val("0");}}</script>'
    html
  end

  def complete_if_column_header
    curr_item = Question.find(id)
    next_item = Question.where('seq > ?', curr_item.seq).order(:seq).first
    html = if next_item.type == 'ColumnHeader'
             '</td></tr>'
           elsif (next_item.type == 'SectionHeader') || (next_item.type == 'TableHeader')
             '</td></tr></table><br/>'
           else
             '<BR/>'
           end
    html
  end

  # This method returns what to display if a student is viewing a filled-out itemnaire
  def view_completed_item(count, answer)
    html = check_previous_item
    html += view_completed_item_answer(count, answer)
    html += view_completed_item_if_column_header
    safe_join([''.html_safe, ''.html_safe], html.html_safe)
  end

  def view_completed_item_answer(count, answer)
    html = if answer.answer == 1
             '<b>' + count.to_s + '. &nbsp;&nbsp;<img src="/assets/Check-icon.png">' + txt + '</b>'
           else
             '<b>' + count.to_s + '. &nbsp;&nbsp;<img src="/assets/delete_icon.png">' + txt + '</b>'
           end
    html
  end

  def view_completed_item_if_column_header
    curr_item = Question.find(id)
    next_item = Question.where('seq > ?', curr_item.seq).order(:seq).first
    html = if next_item.type == 'ColumnHeader'
             '</td></tr>'
           elsif next_item.type == 'TableHeader'
             '</td></tr></table>'
           else
             ''
           end
    html
  end
end
