module spec_api

def GenerateAssignmentName()
	(rand(1000) + 1).to_s + 'SpecID' + (1 + rand(1000)).to_s
end