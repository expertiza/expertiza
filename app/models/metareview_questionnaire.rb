class MetareviewQuestionnaire < Questionnaire
  @print_name = 'Metareview Rubric'

  after_initialize { post_initialization('Metareview') }
  def symbol; super('metareview'); end
  def get_assessments_for(participant); super(participant, :metareviews); end
end
