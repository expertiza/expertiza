describe ViewTranslationSubstitutor do
  let(:test_directory) { '../../spec/test_folder' }
  let(:test_view) { 'example_view' }
  let(:test_translations) { { 'key1' => 'value1', 'key2' => 'value2' } }
  let(:vts) { ViewTranslationSubstitutor.new }

  let(:locale) {
  {
    'views_directory' => {
      'example_view1' => {
        'hello' => 'Hello, world!'
      },
      'example_view2' => {
        'goodbye' => 'Goodbye, world!'
      }
    }
  }
}


  # before do
  #   FileUtils.mkdir_p("#{test_directory}/#{test_view}.html.erb")
  #   File.write("#{test_directory}/#{test_view}.html.erb", "This is a test view.")
  # end

  # after do
  #   FileUtils.rm_rf(test_directory)
  # end

  describe '#substitute' do
    it 'successfully substitutes translations' do
      substitutor = ViewTranslationSubstitutor.new
      expect(substitutor).to receive(:process_directory).with(test_directory, test_translations).and_return({
        test_view => { 'replacements' => [], 'skips' => [] }
      })

      expect(File).to receive(:open).with(/translation_stats.*\.yml/, 'w').and_yield(double('file', write: nil))

      substitutor.substitute(test_directory => test_translations)
    end

    it 'handles a file that does not exist' do
      substitutor = ViewTranslationSubstitutor.new
      expect(substitutor).to receive(:process_directory).with('non_existent_directory', test_translations).and_return({
        'non_existent_view' => '<file not found>'
      })

      expect(File).to receive(:open).with(/translation_stats.*\.yml/, 'w').and_yield(double('file', write: nil))

      substitutor.substitute('non_existent_directory' => test_translations)
    end
  end

  describe '#process_directory' do
    it 'processes each view in the directory' do
      # Ensure that the process_view is expected to be called twice with any arguments
      expect(vts).to receive(:process_view).twice.and_return({})
      # Trigger the method with the updated locale that includes two separate views
      vts.send(:process_directory, 'views_directory', locale['views_directory'])
    end
  end
end

# # require 'rspec'
# describe 'ViewTranslationSubstitutor' do
#   let(:vts) { ViewTranslationSubstitutor.new }
#   # The substitute method is currently broken in the actual model, this spec will fail
#   # describe "#substitute" do
#   #     it "returns" do
#   #         locale = YAML.load_file('config/locales/en_US.yml')['en_US']
#   #         expect(vts.substitute(locale)).to eq(?)
#   #     end
#   # end
#   let(:locale) do
#     {
#       '../../spec/test_folder' => {
#         'example_view' => {
#           'hello' => 'Hello, world!'
#         }
#       }
#     }
#   end

#   describe '#substitute' do
#     context 'when the directory and view files exist' do
#       before do
#         allow(File).to receive(:exist?).and_return(true)
#         # allow(File).to receive(:open).with('./../../spec/test_folder/example_view.html.erb', 'w').and_yield(StringIO.new("Hello, world!"))
#         allow(File).to receive(:open).with(/translation_stats.*\.yml/, 'w').and_yield(StringIO.new(""))
#         # allow(File).to receive(:open).with('./../../spec/test_folder/example_view.html.erb').and_yield(StringIO.new("Hello, world!"))
#         # allow(File).to receive(:open).with(an_instance_of(String), 'w').and_yield(StringIO.new(""))
#       end

#       it 'writes the substituted content to the same file' do
#         # expect(File).to receive(:write).with('translation_stats#{Time.now}.yml", 'w'', anything)
#         expect(File).to receive(:write).with(/translation_stats.*\.yml/, 'w', anything)
#         vts.substitute(locale)
#       end

#       # it 'replaces the correct text with translation keys' do
#       #   expect(File).to receive(:write).with('./../../spec/test_folder/example_view.html.erb', include("<%=t \".hello\"%>"))
#       #   vts.substitute(locale)
#       # end
#     end

#     # context 'when the file does not exist' do
#     #   it 'handles missing files gracefully' do
#     #     allow(File).to receive(:exist?).and_return(false)
#     #     expect { vts.substitute(locale) }.not_to raise_error
#     #   end
#     # end

#     # context 'checking the YAML output for stats' do
#     #   let(:expected_yaml_output) { "---\ntest_folder:\n  example_view:\n    hello:\n      replacements:\n      - Hello, world!\n" }

#     #   it 'creates a YAML file with translation statistics' do
#     #     allow(File).to receive(:exist?).and_return(true)
#     #     allow(File).to receive(:open).with('./../../spec/test_folder/example_view.html.erb').and_yield(StringIO.new("Hello, world!"))
#     #     allow(File).to receive(:open).with(instance_of(String), 'w') do |file_name, _, &block|
#     #       expect(file_name).to match(/translation_stats/)
#     #       block.call(StringIO.new(''))
#     #     end
#     #     expect(File).to receive(:write).with(anything, expected_yaml_output)
#     #     vts.substitute(locale)
#     #   end
#     # end
#   end
# end
