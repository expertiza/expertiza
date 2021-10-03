describe Morpher::Printer::Mixin do
  describe '#description' do
    let(:object) do
      Class.new do
        include Morpher::Printer::Mixin, Adamantium::Flat

        def self.name
          'Foo'
        end

        printer do
          name
        end
      end
    end

    subject { object.new.description }

    it { should eql("Foo\n") }
  end
end
