describe ViewTranslationSubstitutor do
  let(:substitutor) { ViewTranslationSubstitutor.new }
  let(:test_directory) { '../../spec/test_folder' }
  let(:test_view) { 'example_view' }
  let(:non_view) { 'nonexistent_file'}
  let(:test_translations) { { 'hello' => 'Hello, world!' } }
  let(:locale) do {
    '../../spec/test_folder' => {
      'example_view' => {
        'hello' => 'Hello, world!'
      }
    }
  }
  end

  let(:nonexistent_locale) do {
    '../../spec/test_folder' => {
      'nonexistent_file' => {
        'hello' => 'Hello, world!'
      }
    }
  }
  end


  describe '#process_translation' do
    let(:contents) { 'This is a test string with some "text" to be replaced.' }
    let(:key) { 'XXXXXXX' }
    let(:val) { 'text' }

    it 'replaces the correct text with translation keys' do
      replacements, new_contents = substitutor.send(:process_translation, contents, key, val)

      expect(replacements).to include("#{val}")
      expect(new_contents).to include("#{key}")
    end
  end

  # describe '#substitute' do
  #   it 'successfully substitutes translations' do
  #     expect(substitutor).to receive(:process_directory).with(test_directory, test_view => test_translations).and_return({
  #       test_view => { 'replacements' => [], 'skips' => [] }
  #     })

  #     expect(File).to receive(:open).with(/translation_stats.*\.yml/, 'w').and_yield(double('file', write: nil))

  #     substitutor.substitute(locale)
  #   end

  #   it 'handles a file that does not exist' do
  #     expect(substitutor).to receive(:process_directory).with(test_directory, non_view => test_translations).and_return({
  #       test_view => {
  #         'replacements' => ['<%= t ".hesdfgdfgsdfgsdfgllo" %>'],
  #         'skips' => []
  #       }
  #     })

  #     expect(File).to receive(:open).with(/translation_stats.*\.yml/, 'w').and_yield(double('file', write: nil))

  #     substitutor.substitute(nonexistent_locale)
  #   end
  # end
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
