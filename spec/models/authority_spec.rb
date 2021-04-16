describe Authority do
	let(:user1) { create(:student, name: "expertizauser", id: 1) }
	describe '#initialize' do
		it 'sets the current user' do
			authority = Authority.new({current_user: user1})
			expect(authority.current_user).to be(user1)
		end
	end

	describe 'allow?' do
		context 'the current user is an admin' do
			it 'returns true' do

			end
		end
		context 'you try to use the page controller' do
			it 'returns true' do
				controller = 'pages'
				action = nil
				authority = Authority.new({current_user: user1})
				expect(authority.allow?(controller, action)).to eq(true)
			end
		end

		context 'you are not an admin and not trying to access the page controller' do
			it 'returns false' do
				controller = 'menu'
				action = nil
				authority = Authority.new({current_user: user1})
				expect(authority.allow?(controller, action)).to eq(false)
			end
		end
	end
end