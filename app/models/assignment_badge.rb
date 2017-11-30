class AssignmentBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :assignment

  def self.get_threshold(name, assignment_id)
    badge_id = Badge.get_id_from_name(name) 
    b = AssignmentBadge.where("assignment_id = ? AND badge_id = ?",assignment_id,badge_id)[0]
    b.threshold
  end

  def self.saveBadge(thresholdHash,assignment_id)
    print "SAveeeeeeeeeeeeeeeeeee Badgeeeeeeeeeeeeee"
  	if exists?(assignment_id)
  		update(thresholdHash,assignment_id)
  	else
  		create(thresholdHash,assignment_id)
  	end
  end

  # Store in the model entry with appropriate values - First time call
  def self.create(thresholdHash,assignment_id)
	 print thresholdHash
  	Badge.all.each do |badge|
  		current_threshold = badge.name + "Threshold"	
  		print current_threshold
	  	ab = AssignmentBadge.new(:badge_id => badge.id,:assignment_id => assignment_id, :threshold => thresholdHash[current_threshold])
	  	ab.save!
  	end
  end

  def self.update(thresholdHash,assignment_id)
  	badgeHash = {}
  	Badge.all.each do |badge|
  		badgeHash[badge.id] = badge.name + "Threshold"
  	end  	
  	@@a.each do |assignment_badge|
  		assignment_badge.threshold = thresholdHash[badgeHash[assignment_badge.badge_id]]
  		assignment_badge.save!
  	end
  end

  # Check whether assignment badge with this id exists in this model
  def self.exists?(assignment_id)
  	@@a = AssignmentBadge.where(:assignment_id => assignment_id)
  	if @@a.empty?
  		false
  	else
  		true
  	end
  end
end
