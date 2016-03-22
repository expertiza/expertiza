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
      #x = Dir.entries("/")
      #exp_array = x.map &->(i){File.expand_path(i)}
      #expected_array = ["/Users/PranavKulkarni/Documents/zip car/Drivers+license.compressed.pdf", "/Users/PranavKulkarni/Documents/zip car/zipcar+declaration.compressed.pdf"]
      #expect(@dummy_class.files("/Users/PranavKulkarni/Documents/zip car")).to match_array(expected_array)
      #puts @dummy_class.files("/")

      #expect(exp_array).to include(@dummy_class.files("/"))
      #true.should == false
    end
  end


end