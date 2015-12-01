class AddInstitutionInfoToAllUsers < ActiveRecord::Migration
  def self.up
  	#step 1: add instructor info to instructors
  	instructors = ["aarahman", "admin", "ajbudlon", "ajkofink", "annemiek", "clancy", "classen", "cmdodd", "demareed", "dgruehn", "dole", "drwrigh3", "efg", "ehelfant", "fernanda_k_moura", "grandon", "holliday", "hwang26", "irfanemre", "IrinaFalls", "Jkidd", "johnsond", "jpittges", "jtk", "jturnhei", "karl.schmitt", "kelewis", "kzbell", "loyd", "lramach", "maume", "mgdelcar", "mjescuti", "moallemm", "mpanitz", "onafizk", "OTD-iba", "OTD_iba2", "OTD-iba2", "OTD_iba3", "OTD-iba3", "OTD_iba4", "OTD-iba4", "paulf", "pomerantz", "renatamorales", "rkadanj", "rtan", "sbrown3", "tmbarnes", "ucf_coe", "whitel", "yxie1", "oayala", "sringleb", "rschroed", "kbaskett", "jdmorris", "jmorr005"]
  	institutions = ["North Carolina State University", "North Carolina State University", "North Carolina State University", "North Carolina State University", "Erasmus University, Netherlands", "U. of California at Berkeley", "North Carolina State University", "Indiana University-Kokomo", "Oregon State University", "North Carolina State University", "Western Carolina University", "North Carolina State University", "North Carolina State University", "North Carolina State University", "Federal Technological U. of Parana, Brazil", "University of South Florida", "Western Carolina University", "Radford University", "Firat Üniversitesi , Turkey", "UNC-Pembroke", "ODU", "UNC-Wilmington", "Radford University", "Purdue University", "Elizabeth City State University", "Valparaiso University", "SUNY at Buffalo", "Georgia Southern University", "Davenport University", "North Carolina State University", "UNC-Wilmington", "North Carolina State University", "North Carolina State University", "UNC-Wilmington", "Cascadia Community College (WA)", "Firat Üniversitesi , Turkey", "Erasmus University, Netherlands", "Erasmus University, Netherlands", "Erasmus University, Netherlands", "Erasmus University, Netherlands", "Erasmus University, Netherlands", "Erasmus University, Netherlands", "Erasmus University, Netherlands", "North Carolina State University", "UNC-Chapel Hill", "Federal Technological U. of Parana, Brazil", "North Carolina State University", "Kentucky Christian University", "University of Nebraska (Lincoln)", "UNC-Charlotte", "University of Central Florida", "East Carolina University", "George Mason University", "ODU", "ODU", "ODU", "ODU", "ODU", "ODU"]
  	instructors.each_with_index do |instructor_name, index|
  		instructor = User.where(name: instructor_name).first
  		if Institution.exists?(name: institutions[index])
  			institution_id = Institution.where(name: institutions[index]).first.id
  		end 
  		instructor.update_attribute('institutions_id', institution_id) if !institution_id.nil? and !instructor.nil?
  	end
  	assignments = Assignment.all
  	size = assignments.size
  	assignments.each_with_index do |assignment, index|
  		instructor = User.find(assignment.instructor_id)
  		participants = Participant.where(parent_id: assignment.id)
  		participants.each do |participant|
  			#one instructor may attend other instructor's course, but his/her institutions_id should not change.
  			user = User.find(participant.user_id)
  			if !instructors.include? user.name
  				user.update_attribute('institutions_id', instructor.institutions_id)
  			end
  		end
  		print '.' if index % 10 == 0
  	end
  end
end
