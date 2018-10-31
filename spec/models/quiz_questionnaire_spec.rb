describe QuizQuestionnaire do
  let(:questionnaire) { Questionnaire.new name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:questionnaire1) { Questionnaire.new name: "xyz", private: 0, max_question_score: 20, instructor_id: 1234 }

end
