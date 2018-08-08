import * as actions from "..";
import { updateObject } from "../../shared/utility/utility";
import { updateCommentFailure } from "../actions/StudentTeamView";

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
  join_team_requests: null,
  alert: null,
  ad_content: null,
  updateCommentError: null,
  updateCommentMessage: null,
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
        participants: action.payload.participants,
        join_team_requests: action.payload.join_team_requests
      });
    case actions.SET_ALERT_AFTER_INV_SENT:
      return updateObject(state, {alert: action.alert})
    case actions.ADVERTISE_CONTENT_SUCCESS:
      return updateObject(state, {ad_content: action.ad_content })
    case actions.updateCommentSuccess:
      return updateObject(state, {updateCommentMessage: action.message} )
    case updateCommentFailure:
      return updateObject(state, {updateCommentError: action.error})
    default:
      return state;
  }
};

export default studentTeamView;
