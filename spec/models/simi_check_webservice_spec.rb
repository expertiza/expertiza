xdescribe 'SimiCheckWebservice' do
  def poll(comp_id)
    is_success = false
    until is_success
      begin
        response = SimiCheckWebService.get_similarity_nxn(comp_id)
        is_success = (response.code == 200)
      rescue StandardError
        sleep(2)
        next
      end
    end
  end

  describe '.get_all_comparisons' do
    context 'any time called' do
      it 'returns a response with code 200 and body containing all comparisons' do
        response = SimiCheckWebService.all_comparisons
        json_response = JSON.parse(response.body)
        expect(response.code).to eql(200)
        expect(json_response['comparisons']).to be_truthy
      end
    end
  end

  describe '.new_comparison' do
    context 'called with a comparison_name' do
      it 'returns a response with code 200, and body containing the name and new id for this comparison' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        expect(response.code).to eql(200)
        expect(json_response['id']).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.delete_comparison' do
    context 'called with a comparison id' do
      it 'returns a response with code 200' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        response = SimiCheckWebService.delete_comparison(comp_id)
        expect(response.code).to eql(200)
      end
    end
  end

  describe '.get_comparison_details' do
    context 'called with a comparison id' do
      it 'returns a response with code 200 and body containing info about the comparison' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        response = SimiCheckWebService.get_comparison_details(comp_id)
        json_response = JSON.parse(response.body)
        expect(response.code).to eql(200)
        expect(json_response['name']).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.update_comparison' do
    context 'called with a new comparison name' do
      it 'returns a response with code 200 and body containing info about the comparison' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        response = SimiCheckWebService.update_comparison(comp_id, 'updated name')
        expect(response.code).to eql(200)
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.upload_file' do
    context 'called with a comparison id and filepath' do
      it 'returns a response with code 200 and body containing info about the file' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        response = SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        expect(response.code).to eql(200)
        expect(json_response['id']).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.delete_files' do
    context 'called with a comparison id and filenames to delete' do
      it 'returns a response with code 200' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        test_upload_text = 'This is some sample text.'
        filename = 'test_upload.txt'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        response = SimiCheckWebService.delete_files(comp_id, [filename])
        expect(response.code).to eql(200)
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.get_similarity_nxn' do
    context 'called with a comparison id' do
      it 'returns a response with code 200 and body containing info about the results' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        test_upload_text = 'This is some more sample text.'
        filepath = '/tmp/test_upload2.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        SimiCheckWebService.post_similarity_nxn(comp_id)
        poll(comp_id)
        response = SimiCheckWebService.get_similarity_nxn(comp_id)
        expect(response.code).to eql(200)
        json_response = JSON.parse(response.body)
        expect(json_response['similarities']).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.visualize_similarity' do
    context 'called with a comparison id' do
      it 'returns a response with code 200 and body containing the visualize url path' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        test_upload_text = 'This is some more sample text.'
        filepath = '/tmp/test_upload2.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        SimiCheckWebService.post_similarity_nxn(comp_id)
        poll(comp_id)
        response = SimiCheckWebService.visualize_similarity(comp_id)
        expect(response.code).to eql(200)
        expect(response.body).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe '.visualize_comparison' do
    context 'called with a comparison id and two filenames' do
      it 'returns a response with code 200 and body containing the visualize url path' do
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response['id']
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        file1_id = JSON.parse(SimiCheckWebService.upload_file(comp_id, filepath).body)['id']
        File.delete(filepath) if File.exist?(filepath)
        test_upload_text = 'This is some more sample text.'
        filepath = '/tmp/test_upload2.txt'
        File.open(filepath, 'w') { |file| file.write(test_upload_text) }
        file2_id = JSON.parse(SimiCheckWebService.upload_file(comp_id, filepath).body)['id']
        File.delete(filepath) if File.exist?(filepath)
        SimiCheckWebService.post_similarity_nxn(comp_id)
        poll(comp_id)
        response = SimiCheckWebService.visualize_comparison(comp_id, file1_id, file2_id)
        expect(response.code).to eql(200)
        expect(response.body).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end
end
