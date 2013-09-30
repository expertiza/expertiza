require 'spec_helper'

describe ContentPage do
  let(:content_page) { ContentPage.new }

  describe 'validations' do
    it 'has a name' do
      content_page.should_not be_valid
    end

    it 'has a unique name' do
      ContentPage.create(name: 'foo').should be_valid
      ContentPage.new(name: 'foo').should_not be_valid
    end
  end

  describe '#url' do
    it 'formats the url by preceeding the name with a slash' do
      content_page.should_receive(:name).and_return 'foo'
      content_page.url.should == '/foo'
    end
  end
end
