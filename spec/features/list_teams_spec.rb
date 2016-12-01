require 'rails_helper'

describe 'List Team' do

  it 'should list all team nodes' do
   # create(:assignment,name:"List_team")
   # @list1=Assignment.find_by(name: 'List_team')
   # create(:assignment_node,node_object_id: @list1.id)
   # assignment_team = create(:assignment_team,name:'List_team1',assignment:Assignment.find_by(name:'List_team'))
   # team_user = create(:team_user,User.where(role_id: 2).first)

    login_as("instructor6")
    @list_team=Assignment.find_by(name:'List_team')
    visit "/teams/list?id=#{@list_team.id}&type=Assignment"

    page.all('#theTable tr').each do |tr|
      expect(tr).to have_content?(assignment_team.name)
    end
  end
end
