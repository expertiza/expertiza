require 'spec_helper'
require_relative '../../../app/helpers/file_helper'

describe FileHelper do


  class DummyClass
  end

  before(:each) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(FileHelper)
  end

  describe "#files" do
    it 'return files present in a dir' do
      expected_array = ["/tmp/expertiza1603/1.txt", "/tmp/expertiza1603/2.txt"]
      expect(@dummy_class.files("/tmp/expertiza1603")).to match_array(expected_array)
    end
  end


end