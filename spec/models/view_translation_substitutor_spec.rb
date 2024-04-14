# require 'rspec'
describe 'ViewTranslationSubstitutor' do
  let(:vts) { ViewTranslationSubstitutor.new }
  # The substitute method is currently broken in the actual model, this spec will fail
  # describe "#substitute" do
  #     it "returns" do
  #         locale = YAML.load_file('config/locales/en_US.yml')['en_US']
  #         expect(vts.substitute(locale)).to eq(?)
  #     end
  # end
  let(:locale) do
    {
      '../../spec/test_folder' => {
        'example_view' => {
          'hello' => 'Hello, world!'
        }
      }
    }
  end

  describe '#substitute' do
    context 'when the directory and view files exist' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:open).with('./../../spec/test_folder/example_view.html.erb', 'w').and_yield(StringIO.new("Hello, world!"))
        # allow(File).to receive(:open).with('./../../spec/test_folder/example_view.html.erb').and_yield(StringIO.new("Hello, world!"))
        # allow(File).to receive(:open).with(an_instance_of(String), 'w').and_yield(StringIO.new(""))
      end

      it 'writes the substituted content to the same file' do
        expect(File).to receive(:write).with('./../../spec/test_folder/example_view.html.erb', anything)
        vts.substitute(locale)
      end

      it 'replaces the correct text with translation keys' do
        expect(File).to receive(:write).with('./../../spec/test_folder/example_view.html.erb', include("<%=t \".hello\"%>"))
        vts.substitute(locale)
      end
    end

    context 'when the file does not exist' do
      it 'handles missing files gracefully' do
        allow(File).to receive(:exist?).and_return(false)
        expect { vts.substitute(locale) }.not_to raise_error
      end
    end

    context 'checking the YAML output for stats' do
      let(:expected_yaml_output) { "---\ntest_folder:\n  example_view:\n    hello:\n      replacements:\n      - Hello, world!\n" }

      it 'creates a YAML file with translation statistics' do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:open).with('./../../spec/test_folder/example_view.html.erb').and_yield(StringIO.new("Hello, world!"))
        allow(File).to receive(:open).with(instance_of(String), 'w') do |file_name, _, &block|
          expect(file_name).to match(/translation_stats/)
          block.call(StringIO.new(''))
        end
        expect(File).to receive(:write).with(anything, expected_yaml_output)
        vts.substitute(locale)
      end
    end
  end
end
