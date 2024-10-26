# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
# require 'fastercsv'
# require 'csv'

module QuestionnaireHelper
  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3

  def self.adjust_advice_size(itemnaire, item)
    # now we only support item advices for scored items
    if item.is_a?(ScoredQuestion)

      max = itemnaire.max_item_score
      min = itemnaire.min_item_score

      QuestionAdvice.delete(['item_id = ? AND (score > ? OR score < ?)', item.id, max, min]) if !max.nil? && !min.nil?

      (itemnaire.min_item_score..itemnaire.max_item_score).each do |i|
        qas = QuestionAdvice.where('item_id = ? AND score = ?', item.id, i)
        item.item_advices << QuestionAdvice.new(score: i) if qas.first.nil?
        QuestionAdvice.delete(['item_id = ? AND score = ?', item.id, i]) if qas.size > 1
      end
    end
  end

# Updates the attributes of itemnaire items based on form data, without modifying unchanged attributes.
  def update_itemnaire_items
    return if params[:item].nil?

    params[:item].each_pair do |k, v|
      item = Question.find(k)
      v.each_pair do |key, value|
        item.send(key + '=', value) unless item.send(key) == value
      end
      item.save
    end
  end

  #Map type to itemnaire
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

  # factory method to create the appropriate itemnaire based on the type
  def itemnaire_factory(type)
    itemnaire = QUESTIONNAIRE_MAP[type]
    if itemnaire.nil?
      flash[:error] = 'Error: Undefined Questionnaire'
    else
      itemnaire.new
    end
  end

end
