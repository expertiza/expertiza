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
    describe "#show" do
      context "when given valid parameters" do
        it "assigns the id parameter to @id" do
          # Test body
        end
  
        it "assigns the model parameter to @model" do
          # Test body
        end
  
        it "assigns the options parameter to @options" do
          # Test body
        end
  
        it "calls the get_delimiter method with the params parameter" do
          # Test body
        end
  
        it "assigns the result of get_delimiter method to @delimiter" do
          # Test body
        end
  
        it "assigns the has_header parameter to @has_header" do
          # Test body
        end
  
        context "when the model is 'AssignmentTeam' or 'CourseTeam'" do
          it "assigns the has_teamname parameter to @has_teamname" do
            # Test body
          end
        end
  
        context "when the model is 'ReviewResponseMap'" do
          it "assigns the has_reviewee parameter to @has_reviewee" do
            # Test body
          end
        end
  
        context "when the model is 'MetareviewResponseMap'" do
          it "assigns the has_reviewee parameter to @has_reviewee" do
            # Test body
          end
  
          it "assigns the has_reviewer parameter to @has_reviewer" do
            # Test body
          end
        end
  
        context "when the model is 'SignUpTopic'" do
          it "assigns 0 to @optional_count" do
            # Test body
          end
  
          it "increments @optional_count by 1 if the category parameter is 'true'" do
            # Test body
          end
  
          it "increments @optional_count by 1 if the description parameter is 'true'" do
            # Test body
          end
  
          it "increments @optional_count by 1 if the link parameter is 'true'" do
            # Test body
          end
        end
  
        it "assigns 0 to @optional_count for other models" do
          # Test body
        end
  
        it "assigns the file parameter to @current_file" do
          # Test body
        end
  
        it "reads the contents of @current_file" do
          # Test body
        end
  
        it "calls the parse_to_grid method with @current_file_contents and @delimiter" do
          # Test body
        end
  
        it "assigns the result of parse_to_grid method to @contents_grid" do
          # Test body
        end
  
        it "calls the parse_to_hash method with @contents_grid and @has_header" do
          # Test body
        end
  
        it "assigns the result of parse_to_hash method to @contents_hash" do
          # Test body
        end
      end
    end
    describe "start" do
      context "when called with valid parameters" do
        it "assigns the id parameter to @id" do
          # test body
        end
  
        it "assigns the expected_fields parameter to @expected_fields" do
          # test body
        end
  
        it "assigns the model parameter to @model" do
          # test body
        end
  
        it "assigns the title parameter to @title" do
          # test body
        end
      end
    end
    describe 'import' do
      context 'when there are no errors during import' do
        it 'logs a success message' do
          # Test scenario
        end
  
        it 'displays an undo link' do
          # Test scenario
        end
  
        it 'redirects to the previous page' do
          # Test scenario
        end
      end
  
      context 'when there are errors during import' do
        it 'logs an error message' do
          # Test scenario
        end
  
        it 'displays the error message in the flash' do
          # Test scenario
        end
  
        it 'redirects to the previous page' do
          # Test scenario
        end
      end
    end
    describe "#import_from_hash" do
      context "when params[:model] is 'AssignmentTeam' or 'CourseTeam'" do
        it "imports teams from the contents hash" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
  
        it "returns any errors encountered during import" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
      end
  
      context "when params[:model] is 'ReviewResponseMap'" do
        it "imports review response maps from the contents hash" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
  
        it "returns any errors encountered during import" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
      end
  
      context "when params[:model] is 'MetareviewResponseMap'" do
        it "imports metareview response maps from the contents hash" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
  
        it "returns any errors encountered during import" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
      end
  
      context "when params[:model] is 'SignUpTopic' or 'SignUpSheet'" do
        it "imports sign up topics or sheets from the contents hash" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
  
        it "returns any errors encountered during import" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
      end
  
      context "when params[:model] is 'AssignmentParticipant' or 'CourseParticipant'" do
        it "imports assignment or course participants from the contents hash" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
  
        it "returns any errors encountered during import" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
      end
  
      context "when params[:model] is 'User'" do
        it "imports users from the contents hash" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
  
        it "returns any errors encountered during import" do
          # Test scenario 1
          # ...
  
          # Test scenario 2
          # ...
        end
      end
    end
    describe '#hash_rows_with_headers' do
      context 'when the model is User, AssignmentParticipant, CourseParticipant, or SignUpTopic' do
        it 'converts the header and body into a hash with header keys and row values' do
          # Test scenario 1
          # Given:
          header = ['Name', 'Email']
          body = [['John Doe', 'john@example.com'], ['Jane Smith', 'jane@example.com']]
          params = { model: 'User' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Name: 'John Doe', Email: 'john@example.com' }, { Name: 'Jane Smith', Email: 'jane@example.com' }])
  
          # Test scenario 2
          # Given:
          header = ['ID', 'Role']
          body = [[1, 'Student'], [2, 'Instructor']]
          params = { model: 'AssignmentParticipant' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ ID: 1, Role: 'Student' }, { ID: 2, Role: 'Instructor' }])
  
          # Test scenario 3
          # Given:
          header = ['Course', 'Participant']
          body = [['Math', 'John Doe'], ['English', 'Jane Smith']]
          params = { model: 'CourseParticipant' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Course: 'Math', Participant: 'John Doe' }, { Course: 'English', Participant: 'Jane Smith' }])
  
          # Test scenario 4
          # Given:
          header = ['Topic', 'Sign Up']
          body = [['Science', 'John Doe'], ['History', 'Jane Smith']]
          params = { model: 'SignUpTopic' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Topic: 'Science', 'Sign Up': 'John Doe' }, { Topic: 'History', 'Sign Up': 'Jane Smith' }])
        end
      end
  
      context 'when the model is AssignmentTeam or CourseTeam' do
        it 'converts the header and body into a hash with teamname and row values' do
          # Test scenario 1
          # Given:
          header = ['Team', 'Member 1', 'Member 2']
          body = [['Team A', 'John Doe', 'Jane Smith'], ['Team B', 'Bob Johnson', 'Alice Brown']]
          params = { model: 'AssignmentTeam', has_teamname: 'true_first' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Team: 'Team A', 'Member 1': 'John Doe', 'Member 2': 'Jane Smith' }, { Team: 'Team B', 'Member 1': 'Bob Johnson', 'Member 2': 'Alice Brown' }])
  
          # Test scenario 2
          # Given:
          header = ['Member 1', 'Member 2', 'Team']
          body = [['John Doe', 'Jane Smith', 'Team A'], ['Bob Johnson', 'Alice Brown', 'Team B']]
          params = { model: 'CourseTeam', has_teamname: 'true_last' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ 'Member 1': 'John Doe', 'Member 2': 'Jane Smith', Team: 'Team A' }, { 'Member 1': 'Bob Johnson', 'Member 2': 'Alice Brown', Team: 'Team B' }])
        end
      end
  
      context 'when the model is ReviewResponseMap' do
        it 'converts the header and body into a hash with reviewee and row values' do
          # Test scenario 1
          # Given:
          header = ['Reviewee', 'Reviewer']
          body = [['John Doe', 'Jane Smith'], ['Bob Johnson', 'Alice Brown']]
          params = { model: 'ReviewResponseMap', has_reviewee: 'true_first' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Reviewee: 'John Doe', Reviewer: 'Jane Smith' }, { Reviewee: 'Bob Johnson', Reviewer: 'Alice Brown' }])
  
          # Test scenario 2
          # Given:
          header = ['Reviewer', 'Reviewee']
          body = [['Jane Smith', 'John Doe'], ['Alice Brown', 'Bob Johnson']]
          params = { model: 'ReviewResponseMap', has_reviewee: 'true_last' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Reviewer: 'Jane Smith', Reviewee: 'John Doe' }, { Reviewer: 'Alice Brown', Reviewee: 'Bob Johnson' }])
        end
      end
  
      context 'when the model is MetareviewResponseMap' do
        it 'converts the header and body into a hash with reviewee and row values' do
          # Test scenario 1
          # Given:
          header = ['Reviewee', 'Reviewer 1', 'Reviewer 2']
          body = [['John Doe', 'Jane Smith', 'Bob Johnson'], ['Alice Brown', 'Mary Davis', 'Tom Wilson']]
          params = { model: 'MetareviewResponseMap', has_reviewee: 'true_first' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ Reviewee: 'John Doe', 'Reviewer 1': 'Jane Smith', 'Reviewer 2': 'Bob Johnson' }, { Reviewee: 'Alice Brown', 'Reviewer 1': 'Mary Davis', 'Reviewer 2': 'Tom Wilson' }])
  
          # Test scenario 2
          # Given:
          header = ['Reviewer 2', 'Reviewer 1', 'Reviewee']
          body = [['Bob Johnson', 'Jane Smith', 'John Doe'], ['Tom Wilson', 'Mary Davis', 'Alice Brown']]
          params = { model: 'MetareviewResponseMap', has_reviewee: 'true_last' }
          # When:
          result = hash_rows_with_headers(header, body, params)
          # Then:
          expect(result).to eq([{ 'Reviewer 2': 'Bob Johnson', 'Reviewer 1': 'Jane Smith', Reviewee: 'John Doe' }, { 'Reviewer 2': 'Tom Wilson', 'Reviewer 1': 'Mary Davis', Reviewee: 'Alice Brown' }])
        end
      end
    end
    describe 'parse_to_hash' do
      context 'when has_header is true' do
        it 'returns a hash with header and body' do
          # Test scenario 1
          # Given an import grid with a header and body
          # When parse_to_hash is called with the import grid and true as has_header
          # Then it should return a hash with the header and body
  
          # Test scenario 2
          # Given an import grid with a header and body
          # When parse_to_hash is called with the import grid and true as has_header
          # Then it should return a hash with the header and body
        end
      end
  
      context 'when has_header is false' do
        it 'returns a hash with nil header and body' do
          # Test scenario 3
          # Given an import grid without a header
          # When parse_to_hash is called with the import grid and false as has_header
          # Then it should return a hash with nil header and the import grid as body
  
          # Test scenario 4
          # Given an import grid without a header
          # When parse_to_hash is called with the import grid and false as has_header
          # Then it should return a hash with nil header and the import grid as body
        end
      end
    end
    describe "#parse_to_grid" do
      context "when given contents and delimiter" do
        it "returns a grid of parsed lines" do
          # Test case 1
          # Given contents: "1,2,3\n4,5,6\n7,8,9\n"
          # Given delimiter: ","
          # Expected output: [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
  
          # Test case 2
          # Given contents: "apple,banana,orange\ngrape,kiwi,mango\n"
          # Given delimiter: ","
          # Expected output: [["apple", "banana", "orange"], ["grape", "kiwi", "mango"]]
  
          # Test case 3
          # Given contents: "1|2|3\n4|5|6\n7|8|9\n"
          # Given delimiter: "|"
          # Expected output: [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
  
          # Test case 4
          # Given contents: "Hello World\nThis is a test\n"
          # Given delimiter: " "
          # Expected output: [["Hello", "World"], ["This", "is", "a", "test"]]
  
          # Test case 5
          # Given contents: "1,2,3\n\n4,5,6\n\n7,8,9\n"
          # Given delimiter: ","
          # Expected output: [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
        end
      end
    end
    describe 'get_delimiter' do
      context 'when delim_type is "comma"' do
        it 'returns a comma delimiter' do
          # Test body
        end
      end
  
      context 'when delim_type is "space"' do
        it 'returns a space delimiter' do
          # Test body
        end
      end
  
      context 'when delim_type is "tab"' do
        it 'returns a tab delimiter' do
          # Test body
        end
      end
  
      context 'when delim_type is "other"' do
        it 'returns the specified other_char delimiter' do
          # Test body
        end
      end
    end
    describe 'parse_line' do
      context 'when the delimiter is a comma' do
        it 'splits the line by comma and handles double quotes correctly' do
          # test scenario 1
          # line = 'John,Doe,"123, Main St",New York'
          # delimiter = ','
          # expected output = ['John', 'Doe', '123, Main St', 'New York']
  
          # test scenario 2
          # line = 'Jane,Smith,"456, Elm St",Los Angeles'
          # delimiter = ','
          # expected output = ['Jane', 'Smith', '456, Elm St', 'Los Angeles']
        end
      end
  
      context 'when the delimiter is not a comma' do
        it 'splits the line by the given delimiter and removes double quotes' do
          # test scenario 1
          # line = 'John;Doe;"123; Main St";New York'
          # delimiter = ';'
          # expected output = ['John', 'Doe', '123; Main St', 'New York']
  
          # test scenario 2
          # line = 'Jane|Smith|"456| Elm St"|Los Angeles'
          # delimiter = '|'
          # expected output = ['Jane', 'Smith', '456| Elm St', 'Los Angeles']
        end
      end
    end
  
  end