describe 'cake' do
  let(:questionnaire) { Questionnaire.new min_question_score: 0, max_question_score: 5 }
  let(:cake) { Cake.new id: 1, type: 'Cake', seq: 1.0, txt: 'Cake type question?', weight: 1, questionnaire: questionnaire, size: '50' }
  let(:answer) { Answer.new answer: 45 }
  let(:answer1) { Answer.new answer: 50 }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user]) }
  let(:user) { build(:student, id: 1, username: 'no name', name: 'no one', participants: [participant]) }
  let(:participant) { build(:participant, user_id: 1) }
  describe '#edit' do
    it 'returns the html ' do
      html = cake.edit(0).to_s
      expect(html).to eq('<tr><td align="center"><a rel="nofollow" data-method="delete" href="/questions/1">Remove</a></td><td><input size="6" value="1.0" name="question[1][seq]" id="question_1_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[1][txt]" id="question_1_txt" placeholder="Edit question content here">Cake type question?</textarea></td><td><input size="10" disabled="disabled" value="Cake" name="question[1][type]" id="question_1_type" type="text"></td><td><input size="2" value="1" name="question[1][weight]" id="question_1_weight" type="text"></td><td>text area size <input size="3" value="50" name="question[1][size]" id="question_1_size" type="text"></td></tr>')
    end
  end

  describe '#view_question_text' do
    it 'returns the html ' do
      html = cake.view_question_text.to_s
      expect(html).to eq('<TR><TD align="left"> Cake type question? </TD><TD align="left">Cake</TD><td align="center">1</TD><TD align="center">0 to 5</TD></TR>')
    end
  end

  describe '#view_completed_question' do
    it 'returns the html ' do
      html = cake.view_completed_question(0, answer).to_s
      expect(html).to eq('<b>0. Cake type question?</b><div class="c5" style="width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">45</div><b>Comments:</b>')
    end
  end

  describe '#calculate_total_score' do
    it 'Sums up the scores given by all teammates that should be less than or equal to 100' do
      expect(cake.calculate_total_score([answer, answer1])).to eq(95)
    end
  end

  describe '#complete' do
    context 'when size is set to 50, 40' do
      it 'return the html ' do
        allow(answer).to receive(:comments).and_return('comment')
        html = cake.complete(10, answer, 95)
        expect(html).to eq('<table> <tbody> <tr><td><label for="responses_10"">Cake type question?&nbsp;&nbsp;</label><input class="form-control" id="responses_10" min="0" name="responses[10][score]"value="45"type="number" size = 5 onchange="validateScore(this.value,95,this.id)"> </td></tr></tbody></table><td width="10%"></td></tr></table><p>Total contribution so far (excluding current review): 95% </p><textarea cols=50 rows= id="responses_10_comments" name="responses[10][comment]" class="tinymce">comment</textarea><script> function validateScore(val, total_score,id) {
              var int_val = parseInt(val);
              var int_total_score = parseInt(total_score);
              if (int_val+int_total_score > 100 || int_val < 0)
              {
                alert("Total contribution cannot exceed 100 or be a negative value, current total: " + (int_val+int_total_score));
                document.getElementById(id).value = 0
              }
            }</script>')
      end
    end
    context 'when size has not been set' do
      it 'defaults to 70 and 1' do
        cake.size = nil
        allow(answer).to receive(:comments).and_return('comment')
        html = cake.complete(10, answer, 95)
        expect(html).to eq('<table> <tbody> <tr><td><label for="responses_10"">Cake type question?&nbsp;&nbsp;</label><input class="form-control" id="responses_10" min="0" name="responses[10][score]"value="45"type="number" size = 5 onchange="validateScore(this.value,95,this.id)"> </td></tr></tbody></table><td width="10%"></td></tr></table><p>Total contribution so far (excluding current review): 95% </p><textarea cols=70 rows=1 id="responses_10_comments" name="responses[10][comment]" class="tinymce">comment</textarea><script> function validateScore(val, total_score,id) {
              var int_val = parseInt(val);
              var int_total_score = parseInt(total_score);
              if (int_val+int_total_score > 100 || int_val < 0)
              {
                alert("Total contribution cannot exceed 100 or be a negative value, current total: " + (int_val+int_total_score));
                document.getElementById(id).value = 0
              }
            }</script>')
      end
    end
  end

  describe '#get_total_score_for_question' do
    context 'when the review is a Teammate Review Response Map' do
      it 'returns the scores of the team' do
        arr = [answer, answer1]
        allow(Team).to receive(:joins).with([:teams_users, teams_users: [{ user: :participants }]]).and_return(arr)
        allow(arr).to receive(:where).with('participants.id = ? and teams.parent_id in (?)', 1, 1).and_return([team])
        allow(cake).to receive(:get_answers_for_teammatereview).with(1, 1, 1, 1, 1).and_return(arr)
        expect(cake.get_total_score_for_question('TeammateReviewResponseMap', 1, 1, 1, 1)).to eq(95)
      end
    end
    context 'when the question is not a teammate review response' do
      it 'returns zero' do
        arr = [answer, answer1]
        allow(Team).to receive(:joins).with([:teams_users, teams_users: [{ user: :participants }]]).and_return(arr)
        allow(arr).to receive(:where).with('participants.id = ? and teams.parent_id in (?)', 1, 1).and_return([team])
        allow(cake).to receive(:get_answers_for_teammatereview).with(1, 1, 1, 1, 1).and_return(arr)
        expect(cake.get_total_score_for_question('NotTeammateReviewResponseMap', 1, 1, 1, 1)).to eq(nil)
      end
    end
  end

  describe '#get_answers_for_teammatereview' do
    it 'gets an array of answers' do
      arr1 = []
      part = [participant]
      allow(Participant).to receive(:joins).with(user: :teams_users).and_return(arr1)
      allow(arr1).to receive(:where).with('teams_users.team_id in (?) and participants.parent_id in (?)', 1, 1).and_return(part)
      allow(part).to receive(:ids).and_return([1])
      allow(Answer).to receive(:joins).with([{ response: :response_map }, :question]).and_return(arr1)
      allow(arr1).to receive(:where).with("response_maps.reviewee_id in (?) and response_maps.reviewed_object_id = (?)
      and answer is not null and response_maps.reviewer_id in (?) and answers.question_id in (?) and response_maps.reviewee_id not in (?)", [1], 1, 1, 1, 1).and_return([answer, answer1])
      expect(cake.get_answers_for_teammatereview(1, 1, 1, 1, 1))
    end
  end
end
