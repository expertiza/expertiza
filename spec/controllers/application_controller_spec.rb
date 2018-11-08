require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'remove_non_utf8' do
    it 'should not remove utf8 characters' do
      controller.params[:key]='abc漢字123!@$'
      controller.filter_utf8
      controller.params[:key].should eql 'abc漢字123!@$'
    end
    it 'should remove non utf8 characters' do
      controller.params[:key]="a\xC2a"
      controller.filter_utf8
      controller.params[:key].should eql 'aa'
    end
  end
end
