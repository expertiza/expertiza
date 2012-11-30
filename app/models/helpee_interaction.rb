class HelpeeInteraction < Interaction

  def self.find_interactions(participant_id)

    participant_team = AssignmentParticipant.find(participant_id).team


    helper_entries = HelperInteraction.find_all_by_team_id(participant_team.id)
    helpee_entries = HelpeeInteraction.find_all_by_team_id(participant_team.id)


    interactions = Hash.new
    for entry in helper_entries
      id = entry.participant_id
      name = Participant.find(entry.participant_id).user.name
      interactions[id] = Hash.new
      interactions[id][:name] = name
      interactions[id][:helper_entry] =  entry
      interactions[id][:status] = entry.status
    end

    for entry in helpee_entries
      id = entry.participant_id
      name = Participant.find(entry.participant_id).user.name

      if interactions[id].nil?
        interactions[id] = Hash.new
      end

      interactions[id][:name] =  name
      interactions[id][:score] = entry.score
      interactions[id][:helpee_entry] =  entry
      interactions[id][:status] = entry.status
    end
    return interactions

  end


  def self.total_score(participant)
    id = participant.id
    participant_interactions = HelpeeInteraction.find_all_by_participant_id(participant.id)
    score = 0

    participant_interactions.each do|interaction|
      if(interaction.status=="Approved" and interaction.score)
        score = score + interaction.score
      end
    end

    return score
  end

end