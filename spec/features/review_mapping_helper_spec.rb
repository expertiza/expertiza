require 'rspec'

describe 'Tests Review report' do
  before(:each) do
    create(:instructor)
    create(:assignment, course: nil, name: 'Test Assignment')
    assignment_id = Assignment.where(name: 'Test Assignment')[0].id
    login_as 'instructor6'
    visit "/reports/response_report?id=#{assignment_id}"
    click_on 'View'
  end

  it "can display review metrics" do
    expect(page).to have_content('Metrics')
  end

  it "can display review grades of each round" do
    expect(page).to have_content('Score awarded')
  end

  it "can display reviews done" do
    expect(page).to have_content('Reviews done')
  end

  it "can display Reviewer" do
    expect(page).to have_content('Reviewer')
  end

  it "can display team reviewed" do
    expect(page).to have_content('Team reviewed')
  end
end

describe "Test Author feedback report" do
  before(:each) do
    create(:instructor)
    create(:assignment, course: nil, name: 'Test Assignment')
    assignment_id = Assignment.where(name: 'Test Assignment')[0].id
    login_as 'instructor6'
    visit "/reports/response_report?id=#{assignment_id}"
    page.select("Author feedback report", :from => "report[type]")
    click_button "View"
  end

  it "can display rejoinder" do
    expect(page).to have_content('Rejoinder')
  end

  it "can display author feedbacks done" do
    expect(page).to have_content('author feedbacks done')
  end

  it "can display Review response rejoined" do
    expect(page).to have_content('Review response rejoined ')
  end

  it "can display Last rejoined at" do
    expect(page).to have_content('Last rejoined at')
  end
end

describe "Test Teammate Review report" do
  before(:each) do
    create(:instructor)
    create(:assignment, course: nil, name: 'Test Assignment')
    assignment_id = Assignment.where(name: 'Test Assignment')[0].id
    login_as 'instructor6'
    visit "/reports/response_report?id=#{assignment_id}"
    page.select("Teammate review report", :from => "report[type]")
    click_button "View"
  end

  it "can display Reviewer" do
    expect(page).to have_content('Reviewer')
  end

  it "can display teammate reviews done" do
    expect(page).to have_content('teammate reviews done')
  end

  it "can display Teammate reviewed" do
    expect(page).to have_content('Teammate reviewed')
  end

  it "can display Last reviewed at" do
    expect(page).to have_content('Last reviewed at')
  end
end

RSpec.describe ReviewMappingHelper, :type => :helper do
  describe "test get_css_style_for_calibration_report" do
    it "should return correct css for calibration report" do
      expect(helper.get_css_style_for_calibration_report(1)).to eq('c4')
      expect(helper.get_css_style_for_calibration_report(0)).to eq('c5')
      expect(helper.get_css_style_for_calibration_report(2)).to eq('c3')
      expect(helper.get_css_style_for_calibration_report(3)).to eq('c2')
      expect(helper.get_css_style_for_calibration_report(4)).to eq('c1')
    end
  end
end