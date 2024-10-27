class QuizResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :contributor, class_name: 'Participant', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :quiz_questionnaire, class_name: 'QuizQuestionnaire', foreign_key: 'reviewed_object_id', inverse_of: false
  belongs_to :assignment, class_name: 'Assignment', inverse_of: false
  has_many :quiz_responses, foreign_key: :map_id, dependent: :destroy, inverse_of: false

  def questionnaire
    quiz_questionnaire
  end

  def get_title
    'Quiz'
  end

  def delete
    response.delete unless response.nil?
    destroy
  end

  def self.mappings_for_reviewer(participant_id)
    QuizResponseMap.where(reviewer_id: participant_id)
  end

  def quiz_score
    questionnaire_id = reviewed_object_id # the reviewed id is questionnaire id in response map table
    response_id = begin
                    response.first.id
                  rescue StandardError
                    nil
                  end

    # quiz not taken yet
    return 'N/A' if response_id.nil?

    # for each question in quiz, each selected option on an answer is saved in answers table with 0 / 1 value if correct or incorrect
    # this causes issue in percent calculations as a multiple choice answer may get counted multiple times depending on user selection
    # the group by in the query ensures each question is considered only once for percent calculation
    calc_score_query = "SELECT (SUM(q_wt * s_score) / SUM(q_wt)) * 100 as graded_percent
                        FROM (
	                            SELECT s_question_id, MAX(question_weight) as q_wt, MAX(s_score) as s_score
	                            FROM score_views
	                            WHERE q1_id = ? AND s_response_id = ?
	                            GROUP BY s_question_id
                              ) AS TEMP"

    # if quiz taken, get the total percent score obtained
    calculated_score = ScoreView.find_by_sql [calc_score_query, questionnaire_id, response_id]

    if calculated_score.nil? || calculated_score[0].nil? || calculated_score[0].graded_percent.nil?
      return 'N/A'
    end

    # convert the obtained percentage to float and round it to 1st precision
    calculated_score[0].graded_percent.to_f.round(1)
  end
end
