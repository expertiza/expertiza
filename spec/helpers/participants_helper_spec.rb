describe ParticipantsHelper do
    describe '#define_attributes' do
        context 'when define_attributes is called' do
            #Checking if attributes have been correctly defined
            line_split = ['Test1','test@ncsu.edu']
            config = {'name'=>'test2','email'=>'1'}

            it 'returns correct hash "attributes" when define_attributes is called' do
                allow(Role).to receive(:find_by).with({:name=>'Student'}).and_return(1)
                attribute = ParticipantsHelper.define_attributes(line_split,config)
                expect(attribute['role_id']).to eq(1)
                expect(attribute['username']).to eq('Test1')
                expect(attribute['name']).to eq('test2')
                expect(attribute['email']).to eq('test@ncsu.edu')
                expect(attribute['password'].length).to eq(8)
                expect(attribute['email_on_submission']).to eq(1)
                expect(attribute['email_on_review']).to eq(1)
                expect(attribute['email_on_review_of_review']).to eq(1)
            end
        end
    end

    describe '#create_new_user' do
        context 'when create_new_user is called' do
            #Checking if a user has een correctly created
            let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, username: 'Instructor1') }
            
            it 'returns correct user when create_new_user is called' do
                attributes = {'role_id' => 1, 'username' => 'Test1', 'name' => 'test2', 'email' => 'test@ncsu.edu', 'email_on_submission' => 1, 'email_on_review' => 1, 'email_on_review_of_review' => 1}
                session = {user: instructor1}
                user = ParticipantsHelper.create_new_user(attributes, session)
                expect(user['role_id']).to eq(1)
                expect(user['username']).to eq('Test1')
                expect(user['name']).to eq('test2')
                expect(user['email']).to eq('test@ncsu.edu')
                expect(user['email_on_submission']).to eq(true)
                expect(user['email_on_review']).to eq(true)
                expect(user['email_on_review_of_review']).to eq(true)
                expect(user.parent_id).to eq(10)
            end
        end
    end

    describe '#participant_permissions' do
        before(:each) do
            include ParticipantsHelper
        end 

        context 'when participant_permissions is called' do
            it 'returns correct authorizations when participant_permissions is called with reader authorization' do
                #Checking permissions for a reader
                result = participant_permissions('reader')
                expect(result).to eq(can_submit: false, can_review: true, can_take_quiz: true, can_mentor: false)
            end

            it 'returns correct authorizations when participant_permissions is called with reviewer authorization' do
                #Checking permissions for a reviewer
                result = participant_permissions('reviewer')
                expect(result).to eq(can_submit: false, can_review: true, can_take_quiz: false, can_mentor: false)
            end

            it 'returns correct authorizations when participant_permissions is called with submitter authorization' do
                #Checking permissions for a submitter
                result = participant_permissions('submitter')
                expect(result).to eq(can_submit: true, can_review: false, can_take_quiz: false, can_mentor: false)
            end

            it 'returns correct authorizations when participant_permissions is called with participant authorization' do
                #Checking permissions for a participant
                result = participant_permissions('paricipant')
                expect(result).to eq(can_submit: true, can_review: true, can_take_quiz: true, can_mentor: false)
            end
        end
    end

    describe '#store_item' do
        #checkingwhen store_item is called
        it 'assigns config[ident]' do
            #checking if config[ident] is properly assigned
            line = "test=Testing\nstore\nitem"
            ident = "test"
            config = {}
            ParticipantsHelper.store_item(line,ident,config)
            expect(config["test"]).to eq("Testingstore\nitem")
        end
    end
end 
