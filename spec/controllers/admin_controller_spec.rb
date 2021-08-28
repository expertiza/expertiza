describe AdminController do

    describe '#action_allowed?' do
        context 'when the student has admin privileges' do
            it 'returns true' do 
                params = {action: 'list_instructors'}
                session[:user].role.name = 'Administrator'
                expect(controller.action_allowed?).to eq(true)
            end
        end
        context 'when the student doesnt have admin privileges' do
            it 'returns false' do
                params = {action: 'remove_instructor'}
                session[:user].role.name = 'Student'
                expect(controller.action_allowed?).to eq(false)
            end
        end
    end

    describe '#list_super_administrators' do
        
    end

    describe '#show_super_administrator' do
        
    end

    describe '#list_administrators' do
        
    end

    describe '#show_administrator' do
        
    end

    describe '#list_instructors' do
        
    end

    describe '#show_instructor' do
        
    end

end