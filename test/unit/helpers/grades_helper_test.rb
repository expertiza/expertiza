require 'test_helper'
require 'grades_helper'


class GradesHelperTest   < ActionView::TestCase
  include GradesHelper
  fixtures :questions, :question_types , :scores
  # Called before every test method runs. Can be used
  # to set up fixture information.

  def test_get_accordion
    assert_equal get_accordion_title(nil, "pol"), render(:partial=>'response/accordion',:locals =>{:is_first=>true, :title=>"pol"})
    assert_not_equal get_accordion_title("politics", "pol"), render(:partial=>'response/accordion',:locals =>{:is_first=>true, :title=>"pol"})
    assert_equal get_accordion_title("politics", "pol"), render(:partial=>'response/accordion',:locals =>{:is_first=>false, :title=>"pol"})
  end
  def test_find_question_type_checkbox
    file_url=''

    question = Question.find(questions(:question1))

    ques_type = QuestionType.find(question_types(:questiontype1))

    score = Score.find(scores(:score0))
    score_range=[1,2,3,4,5]
    @val=find_question_type(question, ques_type, 0, true, file_url, score, score_range)


    view_output ="<img src=\"/images/delete_icon.png\">" + question.txt + "<br/>"
    q_parameter =  ques_type.parameters.split("::")
    table_hash=construct_table(q_parameter)

    param1 = "response/checkbox"
    param2 = {:ques_num => 0, :ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}



    assert_equal find_question_type(question, ques_type, 0, true, file_url, score, score_range) ,render_ui(param1,param2)
  end

  def test_find_question_type_dropdown
    file_url=''

    question = Question.find(questions(:question1))

    ques_type = QuestionType.find(question_types(:questiontype5))
    score = Score.find(scores(:score0))
    score_range=[1,2,3,4,5]
    @val=find_question_type(question, ques_type, 0, true, file_url, score, score_range)

    view_output = "testing this stuff"
    dd_values = ["Edit Rubric", "No Values"]
    q_parameter =  ques_type.parameters.split("::")
    table_hash=construct_table(q_parameter)

    param1 = "response/dropdown"
    param2 = {:ques_num => 0, :ques_text => question.txt, :options => dd_values, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}

  end

  def test_find_question_type_TextArea
    size="40x5"
    file_url=''
    question = Question.find(questions(:question3))
    ques_type = QuestionType.find(question_types(:questiontype2))
    score = Score.find(scores(:score1))
    score_range=[1,2,3,4,5]
    view_output = nil
    is_view = true
    if is_view
      view_output = "No Response"
      if !score.comments.nil?
        view_output = score.comments
      end
    end
    q_parameter =  ques_type.parameters.split("::")
    table_hash=construct_table(q_parameter)
    param1 = "response/textarea"
    param2 = {:ques_num => 0, :area_size => size,:ques_text => question.txt, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
    assert_equal find_question_type(question, ques_type, 0, true, file_url, score, score_range) ,render_ui(param1,param2)
  end

  def test_find_question_type_uploadfile
    file_url=''
    question = Question.find(questions(:question3))
    ques_type = QuestionType.find(question_types(:questiontype3))
    is_view=true
    view_output = nil
    score = Score.find(scores(:score1))
    if is_view
      view_output = "No Response"
      if !score.comments.nil?
        view_output = score.comments
      end
    end
    q_parameter =  ques_type.parameters.split("::")
    table_hash=construct_table(q_parameter)
    score_range=[1,2,3,4,5]
    view_output = "File has not been uploaded"
    if !file_url.nil?
      view_output = file_url.to_s
    end
    param1 = "response/fileUpload"
    param2 =  {:ques_num => 0, :ques_text => question.txt, :view => view_output}
    assert_equal find_question_type(question, ques_type, 0, true, file_url, score, score_range) ,render_ui(param1,param2)
  end

  def test_find_question_type_rating
    is_view=true
    file_url=''
    q_number=0
    question = Question.find(questions(:question4))
    ques_type = QuestionType.find(question_types(:questiontype4))
    score = Score.find(scores(:score1))
    score_range=[1,2,3,4,5]
    q_parameter =  ques_type.parameters.split("::")
    table_hash = construct_table(q_parameter)
    view_output = nil
    if is_view
      view_output = "No Response"
      if !score.comments.nil?
        view_output = score.comments
      end
    end
    if !q_parameter[1].nil? && q_parameter[1].length > 0
      curr_ques = q_parameter[1].split("|")[0]
    end
    param1 = "response/dropdown"
    param2 =  {:ques_num => q_number, :ques_text => question.txt, :options => score_range, :table_title => table_hash["table_title"], :table_headers => table_hash["table_headers"], :start_col => table_hash["start_col"], :start_table => table_hash["start_table"], :end_col => table_hash["end_col"], :end_table => table_hash["end_table"], :view => view_output}
    assert_equal find_question_type(question, ques_type, 0, true, file_url, score, score_range) ,render_ui(param1,param2)

  end



end
