# Test cases for the ViewTranslationSubstitutor class.

describe ViewTranslationSubstitutor do
  let(:substitutor) { ViewTranslationSubstitutor.new }
  let(:test_directory) { '../../spec/test_folder' }
  let(:test_view) { 'example_view' }
  let(:test_translations) { { 'hello' => 'Hello, world!' } }

  describe '#substitute' do
    let(:substitutor) { ViewTranslationSubstitutor.new }

    it 'iterates over the locale hash and processes directories' do
      # Create a sample locale hash.
      locale = {
        'dir1' => { 'view1' => { 'key1' => 'val1' } },
        'dir2' => { 'view2' => { 'key2' => 'val2' } }
      }

      # Expect process_directory to be called for each directory in the locale hash.
      expect(substitutor).to receive(:process_directory).with('dir1', { 'view1' => { 'key1' => 'val1' } }).and_return('stats1')
      expect(substitutor).to receive(:process_directory).with('dir2', { 'view2' => { 'key2' => 'val2' } }).and_return('stats2')

      # Expect File.open to be called with a regex matching translation_stats*.yml and write the processed stats to YAML.
      expect(File).to receive(:open).with(/^translation_stats.*\.yml$/, 'w').and_yield(file = double)
      expect(file).to receive(:write).with({ 'dir1' => 'stats1', 'dir2' => 'stats2' }.to_yaml)

      # Call the substitute method with the sample locale hash.
      substitutor.substitute(locale)
    end
  end

  describe '#process_directory' do
    let(:substitutor) { ViewTranslationSubstitutor.new }

    context 'when view_hash is not empty' do
      let(:dir_name) { 'dir1' }
      let(:view_hash) { { 'view1' => { 'key1' => 'val1' } } }

      it 'processes each view in the view_hash' do
        # Stub process_view method to return 'stats1' and ensure it is called with correct arguments.
        allow(substitutor).to receive(:process_view).and_return('stats1')
        dir_stats = substitutor.send(:process_directory, dir_name, view_hash)
        expect(dir_stats).to eq({ 'view1' => 'stats1' })
        expect(substitutor).to have_received(:process_view).with(dir_name, 'view1', { 'key1' => 'val1' })
      end
    end

    context 'when view_hash is empty' do
      let(:dir_name) { 'dir2' }
      let(:view_hash) { {} }

      it 'returns an empty hash' do
        # Call the private method process_directory with an empty view_hash and ensure it returns an empty hash.
        dir_stats = substitutor.send(:process_directory, dir_name, view_hash)
        expect(dir_stats).to eq({})
      end
    end
  end

  # Test cases for the process_view method in the ViewTranslationSubstitutor class.

  describe '#process_view' do
    let(:substitutor) { ViewTranslationSubstitutor.new }
    let(:directory_name) { 'test_folder' }
    let(:view_name) { 'example_view' }
    let(:translations) { { 'key1' => 'value1', 'key2' => 'value2' } }

    context 'when the view file exists' do
      before do
        # Stub File.exist? to return true and File.open to yield "Existing content".
        allow(File).to receive(:exist?).with("./#{directory_name}/#{view_name}.html.erb").and_return(true)
        allow(File).to receive(:open).with("./#{directory_name}/#{view_name}.html.erb", 'w').and_yield(StringIO.new("Existing content"))
      end

      it 'reads the file, processes translations, and writes back the contents' do
        # Expect process_translation to be called for each translation and return modified content and stats.
        expect(substitutor).to receive(:process_translation).with("Existing content", 'key1', 'value1').and_return(['stats1', 'new_content1'])
        expect(substitutor).to receive(:process_translation).with('new_content1', 'key2', 'value2').and_return(['stats2', 'new_content2'])

        # Call the process_view method and expect it to return processed view stats.
        view_stats = substitutor.send(:process_view, directory_name, view_name, translations)

        expect(view_stats).to eq({ 'key1' => 'stats1', 'key2' => 'stats2' })

        # Expect File.open to be called twice with the view file path.
        expect(File).to have_received(:open).with("./#{directory_name}/#{view_name}.html.erb", 'w').twice
      end
    end

    context 'when the view file does not exist' do
      it 'returns "<file not found>"' do
        # Call the process_view method and expect it to return "<file not found>".
        view_stats = substitutor.send(:process_view, directory_name, view_name, translations)
        expect(view_stats).to eq('<file not found>')
      end
    end

    context 'when the alternate view file exists' do
      before do
        # Stub File.exist? to return false for main view file and true for alternate view file.
        allow(File).to receive(:exist?).with("./#{directory_name}/#{view_name}.html.erb").and_return(false)
        allow(File).to receive(:exist?).with("./#{directory_name}/_#{view_name}.html.erb").and_return(true)
        allow(File).to receive(:open).with("./#{directory_name}/_#{view_name}.html.erb", 'w').and_yield(StringIO.new("Existing content"))
      end

      it 'reads the alternate file, processes translations, and writes back the contents' do
        # Expect process_translation to be called for each translation and return modified content and stats.
        expect(substitutor).to receive(:process_translation).with("Existing content", 'key1', 'value1').and_return(['stats1', 'new_content1'])
        expect(substitutor).to receive(:process_translation).with('new_content1', 'key2', 'value2').and_return(['stats2', 'new_content2'])

        # Call the process_view method and expect it to return processed view stats.
        view_stats = substitutor.send(:process_view, directory_name, view_name, translations)

        expect(view_stats).to eq({ 'key1' => 'stats1', 'key2' => 'stats2' })

        # Expect File.open to be called twice with the alternate view file path.
        expect(File).to have_received(:open).with("./#{directory_name}/_#{view_name}.html.erb", 'w').twice
      end
    end
  end

  # Test cases for the process_translation method in the ViewTranslationSubstitutor class.

  describe '#process_translation' do
    let(:contents) { 'This is a test string with some "text" to be replaced.' }
    let(:key) { 'XXXXXXX' }
    let(:val) { 'text' }
    let(:key2) { 'skipped key' }
    let(:val2) { 'string' }
    let(:key3) { 'non-existent key' }
    let(:val3) { 'non-existent val' }

    it 'replaces the correct text with translation keys' do
      # Call process_translation with a valid key and value and expect correct replacements and modified content.
      replacements, new_contents = substitutor.send(:process_translation, contents, key, val)

      expect(replacements).to include("replacements" => ["\"#{val}\""])
      expect(new_contents).to include("#{key}")
    end

    it 'adds to skip when one value is not found but another value is' do
      # Call process_translation with a key and value that partially match the contents and expect skips and unmodified content.
      skips, new_contents = substitutor.send(:process_translation, contents, key2, val2)

      expect(skips).to include("skips" => ["test string with"])
      expect(new_contents).not_to include("#{key2}")
    end

    it 'adds <unmatched> to translation_stats when there is no match' do
      # Call process_translation with a key and value that do not match any part of the contents and expect <unmatched> and unmodified content.
      translation_stats, new_contents = substitutor.send(:process_translation, contents, key3, val3)

      expect(translation_stats).to include("<unmatched>")
      expect(new_contents).not_to include("#{key3}")
    end
  end
end
