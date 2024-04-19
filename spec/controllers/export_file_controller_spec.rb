describe  do
    describe "#action_allowed?" do
      context "when the current user has TA privileges" do
        it "returns true" do
          # Test body
        end
      end
    
      context "when the current user does not have TA privileges" do
        it "returns false" do
          # Test body
        end
      end
    end
    describe 'start' do
      context 'when given valid parameters' do
        it 'sets the model parameter' do
          # Test body
        end
    
        it 'sets the title parameter based on the model' do
          # Test body
        end
    
        it 'sets the id parameter' do
          # Test body
        end
      end
    
      context 'when given invalid parameters' do
        it 'does not set the model parameter' do
          # Test body
        end
    
        it 'does not set the title parameter' do
          # Test body
        end
    
        it 'does not set the id parameter' do
          # Test body
        end
      end
    end
    describe 'find_delim_filename' do
      context 'when delim_type is "comma"' do
        it 'returns a filename with .csv extension and delimiter as comma' do
          # test body
        end
      end
    
      context 'when delim_type is "space"' do
        it 'returns a filename with .csv extension and delimiter as space' do
          # test body
        end
      end
    
      context 'when delim_type is "tab"' do
        it 'returns a filename with .csv extension and delimiter as tab' do
          # test body
        end
      end
    
      context 'when delim_type is "other"' do
        it 'returns a filename with .csv extension and delimiter as other_char' do
          # test body
        end
      end
    end
    describe '#exportdetails' do
      context 'when the delimiter type is specified' do
        it 'exports details to a CSV file with the specified delimiter' do
          # Test setup
          params = { delim_type2: 'comma', other_char2: '', model: 'Assignment', id: 1, details: 'all' }
    
          # Test execution
          exportdetails(params)
    
          # Test expectations
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq('text/csv')
          expect(response.headers['Content-Disposition']).to include('attachment')
          expect(response.headers['Content-Disposition']).to include('_Details.csv')
        end
      end
    
      context 'when the delimiter type is not specified' do
        it 'returns an error flash message and redirects back' do
          # Test setup
          params = { delim_type2: '', other_char2: '', model: 'Assignment', id: 1, details: 'all' }
    
          # Test execution
          exportdetails(params)
    
          # Test expectations
          expect(flash[:error]).to eq("This operation is not supported for Assignment")
          expect(response).to redirect_to(:back)
        end
      end
    
      context 'when the model is not allowed' do
        it 'returns an error flash message and redirects back' do
          # Test setup
          params = { delim_type2: 'comma', other_char2: '', model: 'User', id: 1, details: 'all' }
    
          # Test execution
          exportdetails(params)
    
          # Test expectations
          expect(flash[:error]).to eq("This operation is not supported for User")
          expect(response).to redirect_to(:back)
        end
      end
    end
    describe '#export' do
      context 'when the delimiter type is specified' do
        it 'sets the delimiter type based on the provided parameter' do
          # Test body
        end
    
        it 'finds the filename and delimiter based on the delimiter type and other character parameter' do
          # Test body
        end
      end
    
      context 'when the model is allowed' do
        it 'generates CSV data with the specified delimiter' do
          # Test body
        end
    
        it 'exports the specified model data to the CSV' do
          # Test body
        end
      end
    
      it 'sends the generated CSV data as a file attachment' do
        # Test body
      end
    end
    describe "#export_advices" do
      context "when delim_type is specified" do
        it "exports advices to a CSV file with specified delimiter" do
          # Test setup
          params = { delim_type: "comma", other_char: nil, model: "Question", options: { include_header: true }, id: 1 }
          allow(Object).to receive(:const_get).with("QuestionAdvice").and_return(double(export_fields: ["field1", "field2"], export: nil))
          allow(CSV).to receive(:generate).and_return("csv_data")
          allow(controller).to receive(:send_data)
    
          # Test execution
          controller.export_advices
    
          # Test expectations
          expect(CSV).to have_received(:generate).with(col_sep: ",")
          expect(Object).to have_received(:const_get).with("QuestionAdvice")
          expect(Object.const_get("QuestionAdvice")).to have_received(:export_fields).with({ include_header: true })
          expect(Object.const_get("QuestionAdvice")).to have_received(:export).with("csv_data", 1, { include_header: true })
          expect(controller).to have_received(:send_data).with("csv_data", type: 'text/csv; charset=iso-8859-1; header=present', disposition: "attachment; filename=filename")
        end
      end
    
      context "when delim_type is not specified" do
        it "exports advices to a CSV file with default delimiter" do
          # Test setup
          params = { delim_type: nil, other_char: nil, model: "Question", options: { include_header: true }, id: 1 }
          allow(Object).to receive(:const_get).with("QuestionAdvice").and_return(double(export_fields: ["field1", "field2"], export: nil))
          allow(CSV).to receive(:generate).and_return("csv_data")
          allow(controller).to receive(:send_data)
    
          # Test execution
          controller.export_advices
    
          # Test expectations
          expect(CSV).to have_received(:generate).with(col_sep: ";")
          expect(Object).to have_received(:const_get).with("QuestionAdvice")
          expect(Object.const_get("QuestionAdvice")).to have_received(:export_fields).with({ include_header: true })
          expect(Object.const_get("QuestionAdvice")).to have_received(:export).with("csv_data", 1, { include_header: true })
          expect(controller).to have_received(:send_data).with("csv_data", type: 'text/csv; charset=iso-8859-1; header=present', disposition: "attachment; filename=filename")
        end
      end
    
      context "when model is not allowed" do
        it "does not export advices" do
          # Test setup
          params = { delim_type: "comma", other_char: nil, model: "Answer", options: { include_header: true }, id: 1 }
          allow(Object).to receive(:const_get).with("QuestionAdvice").and_return(double(export_fields: ["field1", "field2"], export: nil))
          allow(CSV).to receive(:generate)
          allow(controller).to receive(:send_data)
    
          # Test execution
          controller.export_advices
    
          # Test expectations
          expect(CSV).not_to have_received(:generate)
          expect(Object).not_to have_received(:const_get)
          expect(controller).not_to have_received(:send_data)
        end
      end
    end
    RSpec.describe "export_tags" do
      context "when given names parameter" do
        it "should find user ids based on the names" do
          # Test code
        end
    
        it "should find students' answer tags based on the user ids" do
          # Test code
        end
    
        it "should generate CSV data with specified attributes" do
          # Test code
        end
    
        it "should set the filename for the CSV file" do
          # Test code
        end
    
        it "should send the CSV data as a file attachment" do
          # Test code
        end
      end
    end
    
    end