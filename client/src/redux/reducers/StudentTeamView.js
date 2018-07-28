import * as actions from "..";
import { updateObject } from "../../shared/utility/utility";

const initialize = {
  student: null,
  current_due_date: null,
  users_on_waiting_list: null,
  teammate_review_allowed: null,
  send_invs: [],
  recieved_invs: null,
  assignment: null,
  assignment_topics: null,
  team: null,
  participants: null,
  team_full: false,
  team_topic: null,
  loaded: false
};

const studentTeamView = (state = initialize, action) => {
  switch (action.type) {
    case actions.STUDENTS_TEAM_VIEW_SUCCESS:
      return updateObject(state, {
        student: action.payload.student,
        current_due_date: action.payload.current_due_date,
        users_on_waiting_list: action.payload.users_on_waiting_list,
        teammate_review_allowed: action.payload.teammate_review_allowed,
        send_invs: action.payload.send_invs,
        recieved_invs: action.payload.recieved_invs,
        assignment: action.payload.assignment,
        loaded: true,
        team: action.payload.team,
        team_full: action.payload.full,
        team_topic: action.payload.team_topic,
        participants: action.payload.participants
      });

    default:
      return state;
  }
};

export default studentTeamView;
