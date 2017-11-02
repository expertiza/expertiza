require 'rails_helper'

describe TagPrompt do

  let(:ct_criterion) { Criterion.new id: 1, type: "Criterion", seq: 1.0, txt: "test txt", weight: 1 }
  let(:ct_cbox) { Criterion.new id: 1, type: "Checkbox", seq: 1.0, txt: "test txt", weight: 1 }
  let(:ct_text) { Criterion.new id: 1, type: "Text", seq: 1.0, txt: "test txt", weight: 1 }
  let(:an_long) { Answer.new question: ct_criterion, answer: 5, comments: "test comments" }
  let(:an_long_text) { Answer.new question: ct_text, answer: 5, comments: "test comments" }
  let(:an_cb) { Answer.new question: ct_cbox, answer: 1 }
  let(:an_short) { Answer.new question: ct_criterion, answer: 5, comments: "yes" }
  let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
  let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, assignment: assg, question_type: "Criterion", answer_length_threshold: 5 }

  it "is valid with valid attributes" do
    expect(TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox")).to be_valid
  end

  it "is invalid without valid attributes" do
    expect(TagPrompt.new).not_to be_valid
  end

  it "returns a checkbox when the control_type is checkbox" do
    tp = TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox")
    tag_dep = TagPromptDeployment.new id: 1, tag_prompt: tp, question_type: "Criterion", answer_length_threshold: 5

    expect(tp.html_control(tag_dep, an_long)).to include("input type=\"checkbox\"")
  end

  it "returns a slider when the control_type is slider" do
    tp = TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Slider")
    tag_dep = TagPromptDeployment.new id: 1, tag_prompt: tp, question_type: "Criterion", answer_length_threshold: 5

    expect(tp.html_control(tag_dep, an_long)).to include("input type=\"range\"")
  end

  it "returns an empty string when the question_type is not Criterion" do
    tp = TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox")
    tag_dep = TagPromptDeployment.new id: 1, tag_prompt: tp, question_type: "Criterion", answer_length_threshold: 5

    expect(tp.html_control(tag_dep, an_cb)).to eql("")
  end

  it "returns an empty string when the answer is too short" do
    tp = TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Slider")
    tag_dep = TagPromptDeployment.new id: 1, tag_prompt: tp, question_type: "Criterion", answer_length_threshold: 5

    expect(tp.html_control(tag_dep, an_short)).to eql("")
  end

  it "returns an empty string when the answer is long but the control type is not Criterion" do
    tp = TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Slider")
    tag_dep = TagPromptDeployment.new id: 1, tag_prompt: tp, question_type: "Criterion", answer_length_threshold: 5

    expect(tp.html_control(tag_dep, an_long_text)).to eql("")
  end
end
