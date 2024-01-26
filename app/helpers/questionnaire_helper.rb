# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
# require 'fastercsv'
# require 'csv'

module QuestionnaireHelper
  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3

  def self.adjust_advice_size(questionnaire, question)
    # now we only support question advices for scored questions
    if question.is_a?(ScoredQuestion)

      max = questionnaire.max_question_score
      min = questionnaire.min_question_score

      QuestionAdvice.delete(['question_id = ? AND (score > ? OR score < ?)', question.id, max, min]) if !max.nil? && !min.nil?

      (questionnaire.min_question_score..questionnaire.max_question_score).each do |i|
        qas = QuestionAdvice.where('question_id = ? AND score = ?', question.id, i)
        question.question_advices << QuestionAdvice.new(score: i) if qas.first.nil?
        QuestionAdvice.delete(['question_id = ? AND score = ?', question.id, i]) if qas.size > 1
      end
    end
  end

# Updates the attributes of questionnaire questions based on form data, without modifying unchanged attributes.
  def update_questionnaire_questions
    return if params[:question].nil?

    params[:question].each_pair do |k, v|
      question = Question.find(k)
      v.each_pair do |key, value|
        question.send(key + '=', value) unless question.send(key) == value
      end
      question.save
    end
  end

  #Map type to questionnaire
  QUESTIONNAIRE_MAP = {
    'ReviewQuestionnaire' => ReviewQuestionnaire,
    'MetareviewQuestionnaire' => MetareviewQuestionnaire,
    'AuthorFeedbackQuestionnaire' => AuthorFeedbackQuestionnaire,
    'TeammateReviewQuestionnaire' => TeammateReviewQuestionnaire,
    'AssignmentSurveyQuestionnaire' => AssignmentSurveyQuestionnaire,
    'SurveyQuestionnaire' => SurveyQuestionnaire,
    'GlobalSurveyQuestionnaire' => GlobalSurveyQuestionnaire,
    'CourseSurveyQuestionnaire' => CourseSurveyQuestionnaire,
    'BookmarkRatingQuestionnaire' => BookmarkRatingQuestionnaire,
    'QuizQuestionnaire' => QuizQuestionnaire
  }.freeze

  # factory method to create the appropriate questionnaire based on the type
  def questionnaire_factory(type)
    questionnaire = QUESTIONNAIRE_MAP[type]
    if questionnaire.nil?
      flash[:error] = 'Error: Undefined Questionnaire'
    else
      questionnaire.new
    end
  end

end
