# This file defines factory methods that are functionally related
# to the Expertiza quiz feature. Factories can be used to create
# objects unique to quizzes, including:
#   QuizQuestionnaire
#   QuizQuestion
#   QuizQuestionChoice
#   QuizResponseMap
#   QuizResponse
#   Answer
#
# Note that many of these classes are subclasses specializing
# in quizzing and that the superclasses have a winder purpose.
# Additionally, objects that are not unique to quizzing but
# which show up in the relationships can be found in
# factories.rb.
FactoryBot.define do
  # Quiz Questionnaire is the main representation of a quiz
  # in the Expertiza model. It shares a one-to-many relationship
  # with QuizQuestion and QuizResponseMap, and foreign keys
  # to an AssignmentTeam. It is important to note that
  # the instructor_id field, a holdover from the Questionnaire
  # superclass, is the field used to store the team id.
  factory :quiz_questionnaire, class: QuizQuestionnaire do
    name 'Quiz Questionnaire'
    instructor_id { AssignmentTeam.first.id || association(:assignment_team).id }
    private 0
    min_question_score 0
    max_question_score 1
    type 'QuizQuestionnaire'
    display_type 'Quiz'
    instruction_loc nil
  end

  # Quiz Question is the main representation of a single question
  # in a quiz questionnaire. It stores the question text, type,
  # and shares a many-to-one relationship with quiz questionnaire.
  # Each quiz question shares a one-to-many relationship with
  # quiz question choices and answers.
  factory :quiz_question, class: QuizQuestion do
    txt 'Question'
    weight 1
    questionnaire { QuizQuestionnaire.first || association(:quiz_questionnaire) }
    quiz_question_choices { [QuizQuestionChoice.first] || association(:quiz_question_choices) }
    seq 1.0
    type 'MultipleChoiceRadio'
  end

  # Quiz Question Choice stores the definition for each individual
  # choice within a question. It foreign keys to its associated
  # question.
  factory :quiz_question_choice, class: QuizQuestionChoice do
    question { QuizQuestion.first || association(:quiz_question) }
    txt 'Answer Choice 1'
    iscorrect 0
  end

  # Quiz Response Map is a relationship between a Quiz Questionnaire,
  # an Assignment Team, and a Participant. The reviewer is an
  # individual participant who is taking the quiz, the reviewee is
  # the team that created the quiz questionnaire.
  factory :quiz_response_map, class: QuizResponseMap do
    quiz_questionnaire { QuizQuestionnaire.first || association(:quiz_questionnaire) }
    reviewer { Participant.first || association(:participant) }
    reviewee_id { Teams.first.id || association(:team).id }
  end

  # Quiz Response represents a single response to a quiz
  # questionnaire. It foreign keys to a quiz response map.
  factory :quiz_response, class: QuizResponse do
    response_map { QuizResponseMap.first || association(:response_map) }
    is_submitted 1
  end

  # Answer records a participants answer to a single quiz
  # question. It shares a many-to-one relationship with
  # quiz question and quiz response.
  factory :answer, class: Answer do
    question { Question.first || association(:question) }
    response { Response.first || association(:response) }
    answer 1
    comments 'Answer text'
  end

  # ScoreView contains data from Questions, Questionnaire
  # and Answer tables and has all the information necessary
  # to calculate weighted grades
  factory :score_view, class: ScoreView do
    q1_id 1
    s_question_id 1
    question_weight 1
    s_score 1
    s_response_id 1
    s_comments 'test comment'
  end
end
