class HelperInteraction < Interaction

  def self.find_interactions(participant_id)
    helper_entries = HelperInteraction.find_all_by_participant_id(participant_id)
    helpee_entries = HelpeeInteraction.find_all_by_participant_id(participant_id)


    interactions = Hash.new
    for entry in helper_entries
      id = entry.team_id
      team_name = entry.team.name
      interactions[id] = Hash.new
      interactions[id][:name] =  team_name
      interactions[id][:status] = entry.status
      interactions[id][:helper_entry] =  entry

    end

    for entry in helpee_entries
      id = entry.team_id
      team_name = entry.team.name

      if interactions[id].nil?
        interactions[id] = Hash.new
      end

      interactions[id][:name] =  team_name
      interactions[id][:score] = entry.score
      interactions[id][:status] = entry.status
      interactions[id][:helpee_entry] =  entry
    end
    return interactions
  end



  def self.participant_record(participant)
    id = participant.id
    record = Hash.new
    record[:helper] = HelperInteraction.find_all_by_participant_id(participant.id)
    record[:helpee] = HelpeeInteraction.find_all_by_team_id(participant.team)
  end

  def self.getAssesments(participant)
    interactions = HelperInteraction.all(:conditions => ["participant_id = :participant_id AND status = 'Approved'",{:participant_id => participant.id}])


  end


end