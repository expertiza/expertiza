include SubmittedContentHelper
describe SubmittedContentHelper do

    describe LocalSubmittedContent do
	#tests LocalSubmittedContent.new() successfully creates entry
        describe '#initialize' do
            it 'should create object using specified params' do
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                expect(content.map_id).to eq(1)
                expect(content.round).to eq(2)
                expect(content.link).to eq("http://google.com")
                expect(content.start_at).to eq("2017-12-05 19:11:52")
                expect(content.end_at).to eq("2017-12-05 20:11:52")
            end
        end

        describe '#to_h'do
            it 'should convert the object to hash representation' do
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                hash_representation = {map_id: 1, round:2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52", created_at: nil, updated_at:nil }
                expect(content.to_h()).to eq(hash_representation)
            end
        end

        describe '#=='do
            it 'should compare two content objects' do
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                expect(content == content).to eq(true)
            end
        end
    end

    describe LocalStorage do

        after(:each) do 
            s = LocalStorage.new()
            s.remove_all()
        end

        describe "#initialize" do
            it "should initialize LocalStorage and read resgistry" do
                storage = LocalStorage.new()
                expect(storage).not_to be_nil
            end
        end

	#Tests that LocalSubmittedContent gets saved to PStore file
        describe "#save" do
            it "should save a instance to the Pstore registry" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                storage.save(content)
                expect(storage.instance_variable_get(:@registry).include? content).to be
            end
        end

        describe "#sync" do
            it "should fetch the registry from pstore" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                storage.save(content)
                storage = nil
                storage = LocalStorage.new()
                expect(storage.sync()[0] == content).to be(true)
            end
        end

	#Tests that where function successfully finds an instance stored in PStore file
        describe "#where" do
            it "should retrieve a single matching instance from Pstore registry" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                content1 = LocalSubmittedContent.new(map_id: 3, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                storage.save(content)
                storage.save(content1)
                expect(storage.where(map_id:1)[0].to_h()).to eq(content.to_h())
            end
        end

	#Returns data that is currently stored in PStore file
        describe "#read" do
            it "should pull updated data from pstore" do
                storage = LocalStorage.new()
                pstore = PStore.new("local_submitted_content.pstore")
                registry = nil
                pstore.transaction do 
                    registry = pstore[:registry]
                end 
                expect(storage.read()).to eq(registry)
            end
        end

	#Saves a LocalSubmittedContent object into the database
        describe "#hard_save" do
            it "should save a instance to the database" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                expect(storage.hard_save(content)).not_to be_nil
            end
        end

	#Saves all LocalSubmittedContent objects into database
        describe("#hard_save_all") do
            it "should save all registry instances to the database" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 5, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                content1 = LocalSubmittedContent.new(map_id: 14, round: 3, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                
                storage.save(content)
                storage.save(content1)
                storage.hard_save_all()

                expect(SubmissionViewingEvent.find_by(map_id: 5)).not_to be_nil
                expect(SubmissionViewingEvent.find_by(map_id: 14)).not_to be_nil
            end
        end

	#Tests that a LocalSubmittedContent objects is removed from PStore file
        describe "#remove" do 
            it "should remove a instance from pstore" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 13, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                storage.save(content)
                storage.remove(content)
                expect(storage.read().include?(content)).to be_falsy
            end
        end

	#Tests that all LocalSubmittedContent objects are removed from PStore file
        describe "#remove_all" do 
            it "should remove all instances from pstore" do
                storage = LocalStorage.new()
                content = LocalSubmittedContent.new(map_id: 13, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                content1 = LocalSubmittedContent.new(map_id: 14, round: 3, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
                storage.save(content)
                storage.save(content1)
                storage.remove_all()
                expect(storage.read().length).to eq(0)
            end
        end
    end
end
