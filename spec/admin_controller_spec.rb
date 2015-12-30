require 'spec_helper'
require 'rails_helper'

describe 'admin_controller' do
  let (:user){User.new(:id => 2, :name => 'admin1')}

  it 'has id 2' do
    user.id.should eql (2)
  end
  it 'is named admin1' do
    user.name.should eql ('admin1')
  end

  it 'should be a new record' do
    user.should be_new_record
  end

end

