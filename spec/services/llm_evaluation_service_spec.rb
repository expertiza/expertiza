require 'rails_helper'

describe LlmEvaluationService do
  let(:assignment) { create(:assignment) }
  let!(:participant) { create(:participant, assignment: assignment) }

  it "calls OpenAI API and parses the response" do
    allow(OpenAI::Client).to receive(:new).and_return(
      double(chat: {
        "choices" => [
          {
            "message" => {
              "content" => '{"grade_for_reviewer": 85, "comment_for_reviewer": "Solid review."}'
            }
          }
        ]
      })
    )

    result = LlmEvaluationService.call({ id: assignment.id })
    expect(result.first[:review_grade][:grade_for_reviewer]).to eq(85)
    expect(result.first[:review_grade][:comment_for_reviewer]).to eq("Solid review.")
  end

  it "handles JSON parsing errors gracefully" do
    allow(OpenAI::Client).to receive(:new).and_return(
      double(chat: {
        "choices" => [
          {
            "message" => {
              "content" => 'INVALID JSON'
            }
          }
        ]
      })
    )

    result = LlmEvaluationService.call({ id: assignment.id })
    expect(result.first[:error]).to eq("Failed to parse GPT response")
  end
end
