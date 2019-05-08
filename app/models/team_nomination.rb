class TeamNomination < ActiveRecord::Base
  belongs_to :badge
  belongs_to :team
  belongs_to :participant, foreign_key: 'nominator_id'
  belongs_to :assignment

  def self.get_nominations course_id
    result_set = TeamNomination.joins(:assignment).where("assignments.course_id = ? and team_nominations.status = ?", course_id, "pending_approval")
    @nominations = []
    result_set.each do |result|
      nomination = {}
      nomination[:id] = result.id
      nomination[:team] = result.team
      nomination[:team_id] = result.team.id
      nomination[:team_name] = result.team.name
      nomination[:badge_id] = result.badge.id
      nomination[:badge_name] = result.badge.name
      nomination[:badge_image_url] = result.badge.image_url
      nomination[:nominator_id] = result.participant.id
      nomination[:nominator_name] = result.participant.name
      nomination[:assignment_id] = result.assignment.id
      nomination[:assignment_name] = result.assignment.name
      nomination[:submitted_links] = result.team.submitted_hyperlinks

      @nominations << nomination
    end

    @nominations = @nominations.group_by { |nomination| [ nomination[:team_id],nomination[:badge_id],nomination[:assignment_id] ] }.map do |id, hashes|
      hashes.reduce do |hash1, hash2|
        hash1.merge(hash2) { |key, v1, v2| v1 == v2 ? v1 : [v1, v2].flatten }
      end
    end
    @nominations
  end
end
