describe 'WritersController' do

  describe '#create' do
    context 'when an author signup' do
      expect(@user.role_id).to eql? 7
    end
    context 'redirect to writer_sessions/new.html.erb' do
      expect(create).to redirect_to(writer_sessions/new.html.erb)
    end
  end
end