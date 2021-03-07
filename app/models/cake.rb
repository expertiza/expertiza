class Cake < ScoredQuestion
    include ActionView::Helpers
    validates :size, presence: true
    #method is called during creation of questionnaire --> when cake type is added to the questionnaire.
    def edit(_count)
      html = '<td align="center"><a rel="nofollow" data-method="delete" href="/questions/' + self.id.to_s + '">Remove</a></td>'
      html += '<td><input size="6" value="' + self.seq.to_s + '" name="question[' + self.id.to_s + '][seq]"'
      html += ' id="question_' + self.id.to_s + '_seq" type="text"></td>'
      html += '<td><textarea cols="50" rows="1" name="question[' + self.id.to_s + '][txt]"'
      html += ' id="question_' + self.id.to_s + '_txt" placeholder="Edit question content here">' + self.txt + '</textarea></td>'
      html += '<td><input size="10" disabled="disabled" value="' + self.type + '" name="question[' + self.id.to_s + '][type]"'
      html += ' id="question_' + self.id.to_s + '_type" type="text"></td>'
      html += '<td><input size="2" value="' + self.weight.to_s
      html += '" name="question[' + self.id.to_s + '][weight]" id="question_' + self.id.to_s + '_weight" type="text"></td>'
      html += '<td>text area size <input size="3" value="' + self.size.to_s
      html += '" name="question[' + self.id.to_s + '][size]" id="question_' + self.id.to_s + '_size" type="text"></td>'
      safe_join(["<tr>".html_safe, "</tr>".html_safe], html.html_safe)
    end
  
    # Method called after clicking on View Questionnaire option
    def view_question_text
      html = '<TD align="left"> ' + self.txt + ' </TD>'
      html += '<TD align="left">' + self.type + '</TD>'
      html += '<td align="center">' + self.weight.to_s + '</TD>'
      questionnaire = self.questionnaire
      html += '<TD align="center">' + questionnaire.min_question_score.to_s + ' to ' + questionnaire.max_question_score.to_s + '</TD>'
      safe_join(["<TR>".html_safe, "</TR>".html_safe], html.html_safe)
    end
  
    # Method is called when completing the percentage contribution text box for a cake question in a review
    def complete(count, answer = nil, total_score)
      if self.size.nil?
        cols = '70'
        rows = '1'
      else
        cols = self.size.split(',')[0]
        rows = self.size.split(',')[1]
      end
      html = '<table> <tbody> <tr><td>'
      html += '<label for="responses_' + count.to_s + '"">' + self.txt + '&nbsp;&nbsp;</label>'
      html += '<input class="form-control" id="responses_' + count.to_s + '" min="0" name="responses[' + count.to_s + '][score]"'
      html += 'value="' + answer.answer.to_s + '"' unless answer.nil?
      html += 'type="number" size = 5 onchange="validateScore(this.value,' + total_score.to_s + ',this.id)"> '
      html += '</td></tr></tbody></table>'
      html += '<td width="10%"></td></tr></table>'
      html += '<p>Total contribution so far (excluding current review): ' + total_score.to_s + '% </p>' #display total
      html += '<textarea cols=' + cols.to_s + ' rows=' + rows.to_s + ' id="responses_' + count.to_s + '_comments"' \
          ' name="responses[' + count.to_s + '][comment]" class="tinymce">'
      html += answer.comments unless answer.nil?
      html += '</textarea>'
      html += '<script> function validateScore(val, total_score,id) {
                var int_val = parseInt(val);
                var int_total_score = parseInt(total_score);                
                if (int_val+int_total_score > 100 || int_val < 0)
                {
                  alert("Total contribution cannot exceed 100 or be a negative value, current total: " + (int_val+int_total_score));
                  document.getElementById(id).value = 0
                }
              }</script>'
      safe_join(["".html_safe, "".html_safe], html.html_safe)
    end
  
    # This method returns what to display if a student is viewing a filled-out questionnaire
    def view_completed_question(count, answer)
      score = answer && !answer.answer.nil? ? answer.answer.to_s : "-"
      html = '<b>' + count.to_s + ". " + self.txt + "</b>"
      html += '<div class="c5" style="width:30px; height:30px;' \
        ' border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">'
      html += score
      html += '</div>'
      html += '<b>Comments:</b>' + answer.comments.to_s
      safe_join(["".html_safe, "".html_safe], html.html_safe)
    end
  
    # Finds all teammates and calculates the total contribution of all members for the question
    def get_total_score_for_question(review_type, question_id, participant_id, assignment_id, reviewee_id)
      # get the reviewer's team id for the currently answered question
      team_id = Team.joins([:teams_users, teams_users: [{user: :participants}]]).where("participants.id = ? and teams.parent_id in (?)", participant_id, assignment_id).first
      if team_id
        team_id = team_id.id
      end
      if review_type == 'TeammateReviewResponseMap'
        answers_for_team_members =  get_answers_for_teammatereview(team_id, question_id, participant_id, assignment_id, reviewee_id)
      end
      calculate_total_score(answers_for_team_members)
    end
  
    # Finds the scores for all teammates for this question
    def get_answers_for_teammatereview(team_id, question_id, participant_id, assignment_id, reviewee_id)
      # get the reviewer's team members for the currently answered question
      team_members = Participant.joins(user: :teams_users).where("teams_users.team_id in (?) and participants.parent_id in (?)", team_id, assignment_id).ids
      # get the reviewer's ratings for his team members
      Answer.joins([{response: :response_map}, :question]).where("response_maps.reviewee_id in (?) and response_maps.reviewed_object_id = (?)
        and answer is not null and response_maps.reviewer_id in (?) and answers.question_id in (?) and response_maps.reviewee_id not in (?)", team_members, assignment_id, participant_id, question_id, reviewee_id).to_a
    end
  
    # Sums up the scores given by all teammates that should be less than or equal to 100
    def calculate_total_score(question_answers)
      question_score = 0.0
      question_answers.each do |ans|
        # calculate score per question
        unless ans.answer.nil?
          question_score += ans.answer
        end
      end
      question_score
    end
  
  end