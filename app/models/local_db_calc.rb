module LocalDBCalc

    def compute_total_score(scores)
        total = 0
        teams = AssignmentTeam.where(parent_id: self.id)
        teams.each do |team|
            response_maps = team.review_mappings
            response_maps.each do |map|
                record = LocalDbScore.where(response_map_id: map.map_id).last
                next if record.nil?
                score = record[:score]
                total += score unless score.nil?
            end
        end
        total
    end

end