describe Badge do
  before(:all) do
    @badge1 = build(:badge, id:100001, name:'test_badge', description: 'test_description', image_name: 'test_image_name')
    @badge2 = build(:badge, id:100002, name: '', description: 'test_description', image_name: 'test_image_name')
    @badge3 = build(:badge, id:100003, name: 'test_name', description: '', image_name: 'test_image_name')
    @badge4 = build(:badge, id:100003, name: 'test_name', description: 'test_description', image_name: '')
  end

  it 'is valid when it has a name and description' do
    expect(@badge1).to be_valid
  end

  it 'is invalid when it does not have a name' do
    expect(@badge2).not_to be_valid
  end

  it 'is invalid when it does not have a description' do
    expect(@badge3).not_to be_valid
  end

  it 'is invalid when it does not have an image name' do
    expect(@badge4).not_to be_valid
  end
end