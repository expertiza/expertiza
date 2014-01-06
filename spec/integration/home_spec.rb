require 'spec_helper'

describe 'home page' do
  it 'welcomes the user' do
    visit '/'
    #save_and_open_page
    page.should have_content('Reusable learning objects through peer review')
  end
end