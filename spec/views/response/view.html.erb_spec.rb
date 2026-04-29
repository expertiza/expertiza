require 'rails_helper'

RSpec.describe 'response/view.html.erb', type: :view do
  let(:round_count) { 1 }
  let(:assignment) { instance_double(Assignment, name: 'Peer Review Assignment', num_review_rounds: round_count) }
  let(:author) { instance_double(User, email: 'author@example.com') }
  let(:participant) { instance_double(AssignmentParticipant, user: author) }
  let(:response_record) do
    instance_double(Response, id: 1, display_as_html: 'Rendered response'.html_safe, visibility: nil)
  end
  let(:map) do
    TeammateReviewResponseMap.new.tap do |response_map|
      allow(response_map).to receive(:get_all_versions).and_return([])
      allow(response_map).to receive(:show_feedback).with(response_record).and_return(''.html_safe)
    end
  end
  let(:instructor_review_score) do
    instance_double(
      InstructorReviewScore,
      score_for_summative: 2,
      score_for_formative: 4,
      feedback_for_formative: 'Add more actionable suggestions.',
      feedback_for_summative: 'Your accuracy assessment was strong.'
    )
  end

  before do
    assign(:title, 'Review')
    assign(:assignment, assignment)
    assign(:participant, participant)
    assign(:response, response_record)
    assign(:map, map)
    assign(:instructor_review_score, instructor_review_score)

    allow(view).to receive(:author_response_index_path).and_return('/response/author')
    allow(view).to receive(:detailed_evaluation_response_index_path).with(id: 1).and_return('/response/detailed_evaluation?id=1')
  end

  it 'shows the normalized formative score out of 10 to students for single-round assignments' do
    student = build(:student)
    allow(view).to receive(:current_user).and_return(student)

    render

    expect(rendered).to include('8 out of 10')
    expect(rendered).to include('Add more actionable suggestions.')
    expect(rendered).not_to include('Total:')
    expect(rendered).not_to include('2 out of 2 for accuracy')
    expect(rendered).not_to include('Your accuracy assessment was strong.')
  end

  it 'shows the formative score out of 5 to students for multi-round assignments' do
    student = build(:student)
    allow(view).to receive(:current_user).and_return(student)
    allow(assignment).to receive(:num_review_rounds).and_return(2)

    render

    expect(rendered).to include('4 out of 5')
    expect(rendered).not_to include('8 out of 10')
    expect(rendered).to include('Add more actionable suggestions.')
  end

  it 'keeps formative and summative details visible to teaching staff' do
    instructor = build(:instructor)
    allow(view).to receive(:current_user).and_return(instructor)

    render

    expect(rendered).to include('Total:')
    expect(rendered).to include('6 out of 7')
    expect(rendered).to include('4 out of 5 for feedback, 2 out of 2 for accuracy')
    expect(rendered).to include('Add more actionable suggestions.')
    expect(rendered).to include('Your accuracy assessment was strong.')
  end
end
