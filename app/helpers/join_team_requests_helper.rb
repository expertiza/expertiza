module JoinTeamRequestsHelper
  def display_request_status(join_team_request)
    status = case join_team_request.status
             when 'P'
               'Pending: A request has been made to join this team.'
             when 'D'
               'Denied: The team has denied your request.'
             when 'A'
               "Accepted: The team has accepted your request.\nYou should receive an invitation in \"Your Team\" page."
             else
               join_team_request.status
             end
    status
  end
end
