FactoryGirl.define do
  factory :team do
    name "Wikipedia contribution_Team2"
    parent_id 999
    #parent_id 741
    type "AssignmentTeam"
    submitted_hyperlinks "---\n- http://water.com\n- http://shed.com"
  end
end
